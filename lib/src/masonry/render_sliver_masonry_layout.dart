part of 'sliver_masonry_layout.dart';

/// Parent data for children of [RenderSliverMasonryLayout].
///
/// Shaped the same way Flutter's own `SliverMultiBoxAdaptorParentData`
/// is (`SliverLogicalParentData` + [ContainerParentDataMixin]): the
/// inherited `layoutOffset` carries each child's main-axis (scroll-axis)
/// position, and [crossAxisOffset] carries its position across the tracks.
class SliverMasonryParentData extends SliverLogicalParentData
    with ContainerParentDataMixin<RenderBox> {
  /// This child's offset from the leading edge of the cross axis — i.e.
  /// which body sub-track or the side track it sits in.
  double crossAxisOffset = 0;
}

/// The layout engine behind [SliverMasonryLayout].
///
/// This is a genuine [RenderSliver]: it reports real [SliverGeometry]
/// (`scrollExtent`, `paintExtent`, `cacheExtent`, `hasVisualOverflow`)
/// computed from the incoming [SliverConstraints].
///
/// **Zone model / width thresholds**
///
/// | Cross-axis extent                          | Mode         |
/// |--------------------------------------------|---------------|
/// | `< bodyMinWidth`                           | collapsed     |
/// | `bodyMinWidth … bodyMinWidth+sideMinWidth` | toggle        |
/// | `≥ bodyMinWidth + sideMinWidth`            | two-column    |
///
/// * **Collapsed** — all items stack in a single full-width column.
/// * **Toggle** — only one zone shown at full width:
///   * `isSideExpanded = true`  → body items render; side items hidden.
///   * `isSideExpanded = false` → side items render; body items hidden.
///   * [MasonryWidth.full] items always render.
/// * **Two-column** — normal body + side layout governed by [bodyMaxWidth],
///   [sideMaxWidth], and [isSideExpanded].
///
/// **Scope note:** masonry positions are inherently sequential (item N's slot
/// depends on the measured height of items `0..N-1`), so this lays out every
/// child on every layout pass rather than skipping invisible ones. This is
/// acceptable for dashboard-sized lists; for very large feeds consider
/// paginating or using `SliverList` instead.
class RenderSliverMasonryLayout extends RenderSliver
    with
        ContainerRenderObjectMixin<RenderBox, SliverMasonryParentData>,
        RenderSliverHelpers {
  RenderSliverMasonryLayout({
    required List<MasonryWidth> sizes,
    required double gap,
    required double bodyMinWidth,
    required double sideMinWidth,
    double? bodyMaxWidth,
    double? sideMaxWidth,
    required bool isSideExpanded,
    int Function(double)? bodyFactory,
  })  : _sizes = sizes,
        _gap = gap,
        _bodyMinWidth = bodyMinWidth,
        _sideMinWidth = sideMinWidth,
        _bodyMaxWidth = bodyMaxWidth,
        _sideMaxWidth = sideMaxWidth,
        _isSideExpanded = isSideExpanded,
        _bodyFactory = bodyFactory;

  // ── Fields ──────────────────────────────────────────────────────────────

  List<MasonryWidth> _sizes;
  List<MasonryWidth> get sizes => _sizes;
  set sizes(List<MasonryWidth> value) {
    if (_sizes == value) return;
    _sizes = value;
    markNeedsLayout();
  }

  double _gap;
  double get gap => _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  double _bodyMinWidth;

  /// Cross-axis extent below which the layout collapses to a single column.
  double get bodyMinWidth => _bodyMinWidth;
  set bodyMinWidth(double value) {
    if (_bodyMinWidth == value) return;
    _bodyMinWidth = value;
    markNeedsLayout();
  }

  double _sideMinWidth;

  /// Minimum usable width for the side zone.
  ///
  /// When `crossAxisExtent < bodyMinWidth + sideMinWidth` the layout enters
  /// **toggle mode**: only one zone is shown at full width, selected by
  /// [isSideExpanded]. [MasonryWidth.full] items always render.
  double get sideMinWidth => _sideMinWidth;
  set sideMinWidth(double value) {
    if (_sideMinWidth == value) return;
    _sideMinWidth = value;
    markNeedsLayout();
  }

  double? _bodyMaxWidth;

  /// Maximum pixel width of the body zone (used when [isSideExpanded] is
  /// `true`). `null` means the body zone consumes all available extent.
  double? get bodyMaxWidth => _bodyMaxWidth;
  set bodyMaxWidth(double? value) {
    if (_bodyMaxWidth == value) return;
    _bodyMaxWidth = value;
    markNeedsLayout();
  }

  double? _sideMaxWidth;

  /// Maximum pixel width of the side zone (used when [isSideExpanded] is
  /// `false`). `null` defaults to 30 % of available extent.
  double? get sideMaxWidth => _sideMaxWidth;
  set sideMaxWidth(double? value) {
    if (_sideMaxWidth == value) return;
    _sideMaxWidth = value;
    markNeedsLayout();
  }

  bool _isSideExpanded;

  /// `true`  → body is dominant (limited by [bodyMaxWidth]).
  /// `false` → side uses [sideMaxWidth]; body fills the rest.
  bool get isSideExpanded => _isSideExpanded;
  set isSideExpanded(bool value) {
    if (_isSideExpanded == value) return;
    _isSideExpanded = value;
    markNeedsLayout();
  }

  int Function(double)? _bodyFactory;

  /// Returns how many equal sub-tracks the body zone should be split into
  /// for a given body width. Body items masonry-pack within those sub-tracks.
  /// `null` → body is a single column.
  int Function(double)? get bodyFactory => _bodyFactory;
  set bodyFactory(int Function(double)? value) {
    if (_bodyFactory == value) return;
    _bodyFactory = value;
    markNeedsLayout();
  }

  // ── RenderSliver overrides ───────────────────────────────────────────────

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SliverMasonryParentData) {
      child.parentData = SliverMasonryParentData();
    }
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      geometry = SliverGeometry.zero;
      return;
    }

    final crossAxisExtent = constraints.crossAxisExtent;

    // Below bodyMinWidth, collapse everything to a single full-width column.
    if (crossAxisExtent < _bodyMinWidth) {
      _layoutCollapsed(crossAxisExtent);
      return;
    }

    // In the range [bodyMinWidth, bodyMinWidth + sideMinWidth) the screen is
    // wide enough for one zone but not both — enter toggle mode.
    if (crossAxisExtent < _bodyMinWidth + _sideMinWidth) {
      _layoutToggle(crossAxisExtent);
      return;
    }

    // ── Compute zone widths ────────────────────────────────────────────
    double bodyW, sideW;
    if (_isSideExpanded) {
      // Body dominant: grow body up to bodyMaxWidth, then give remainder to side.
      bodyW = _bodyMaxWidth != null
          ? math.min(crossAxisExtent, _bodyMaxWidth!)
          : crossAxisExtent;
      sideW = crossAxisExtent - bodyW - _gap;
      // Ensure side meets its minimum — steal from body if necessary.
      if (sideW < _sideMinWidth) {
        sideW = _sideMinWidth;
        bodyW = crossAxisExtent - sideW - _gap;
      }
    } else {
      // Side gets its preferred width, floored at sideMinWidth.
      sideW = _sideMaxWidth != null
          ? math.min(crossAxisExtent - _gap, _sideMaxWidth!)
          : crossAxisExtent * 0.3;
      sideW = math.max(sideW, _sideMinWidth);
      bodyW = crossAxisExtent - sideW - _gap;
    }

    // Fall back to body-only if either zone is below its minimum.
    final bool activeSide = sideW >= _sideMinWidth && bodyW >= _bodyMinWidth;
    if (!activeSide) {
      bodyW = crossAxisExtent;
      sideW = 0.0;
    }

    // ── Body sub-tracks ───────────────────────────────────────────────────
    final int bodySubTracks =
        _bodyFactory != null ? _bodyFactory!(bodyW).clamp(1, 8) : 1;
    final double bodySubTrackW = bodySubTracks > 1
        ? (bodyW - _gap * (bodySubTracks - 1)) / bodySubTracks
        : bodyW;

    // ── Track table ───────────────────────────────────────────────────────
    // Indices 0..(bodySubTracks-1) = body sub-tracks.
    // Index bodySubTracks           = side track (only when activeSide).
    final int totalTracks = bodySubTracks + (activeSide ? 1 : 0);
    final trackMainExtents = List<double>.filled(totalTracks, 0.0);
    final trackX = <double>[
      for (var t = 0; t < bodySubTracks; t++) t * (bodySubTrackW + _gap),
      if (activeSide) bodyW + _gap,
    ];

    // ── Place children ────────────────────────────────────────────────────
    RenderBox? child = firstChild;
    var index = 0;
    while (child != null) {
      final parentData = child.parentData! as SliverMasonryParentData;
      final mw = _sizes[index];

      double itemCrossExtent;
      double crossOffset;
      double mainOffset;

      if (mw == MasonryWidth.full) {
        // ── full: spans everything ────────────────────────────────────────
        final zoneH = trackMainExtents.reduce(math.max);
        crossOffset = 0;
        mainOffset = zoneH == 0 ? 0 : zoneH + _gap;
        itemCrossExtent = crossAxisExtent;

        child.layout(
          constraints.asBoxConstraints(crossAxisExtent: itemCrossExtent),
          parentUsesSize: true,
        );
        final newH = mainOffset + _childMainExtent(child);
        for (var t = 0; t < totalTracks; t++) {
          trackMainExtents[t] = newH;
        }
      } else if (mw == MasonryWidth.body) {
        // ── body: masonry-pack within body sub-tracks ─────────────────────
        var bestT = 0;
        for (var t = 1; t < bodySubTracks; t++) {
          if (trackMainExtents[t] < trackMainExtents[bestT]) bestT = t;
        }
        final bestH = trackMainExtents[bestT];
        crossOffset = trackX[bestT];
        mainOffset = bestH == 0 ? 0 : bestH + _gap;
        itemCrossExtent = bodySubTrackW;

        child.layout(
          constraints.asBoxConstraints(crossAxisExtent: itemCrossExtent),
          parentUsesSize: true,
        );
        trackMainExtents[bestT] = mainOffset + _childMainExtent(child);
      } else {
        // ── side: placed in the side zone ────────────────────────────────
        if (activeSide) {
          final sideTrackIdx = bodySubTracks;
          final sideH = trackMainExtents[sideTrackIdx];
          crossOffset = trackX[sideTrackIdx];
          mainOffset = sideH == 0 ? 0 : sideH + _gap;
          itemCrossExtent = sideW;

          child.layout(
            constraints.asBoxConstraints(crossAxisExtent: itemCrossExtent),
            parentUsesSize: true,
          );
          trackMainExtents[sideTrackIdx] = mainOffset + _childMainExtent(child);
        } else {
          // Side zone collapsed → fall back to body zone placement.
          var bestT = 0;
          for (var t = 1; t < bodySubTracks; t++) {
            if (trackMainExtents[t] < trackMainExtents[bestT]) bestT = t;
          }
          final bestH = trackMainExtents[bestT];
          crossOffset = trackX[bestT];
          mainOffset = bestH == 0 ? 0 : bestH + _gap;
          itemCrossExtent = bodySubTrackW;

          child.layout(
            constraints.asBoxConstraints(crossAxisExtent: itemCrossExtent),
            parentUsesSize: true,
          );
          trackMainExtents[bestT] = mainOffset + _childMainExtent(child);
        }
      }

      parentData
        ..layoutOffset = mainOffset
        ..crossAxisOffset = crossOffset;

      child = childAfter(child);
      index++;
    }

    final totalExtent = trackMainExtents.reduce(math.max);
    final paintExtent =
        calculatePaintOffset(constraints, from: 0, to: totalExtent);
    final cacheExtent =
        calculateCacheOffset(constraints, from: 0, to: totalExtent);

    geometry = SliverGeometry(
      scrollExtent: totalExtent,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: totalExtent,
      hasVisualOverflow: totalExtent > constraints.remainingPaintExtent,
    );
  }

  /// Lays out all children in a single full-width column.
  ///
  /// Used when the cross-axis extent is below [bodyMinWidth].
  void _layoutCollapsed(double crossExtent) {
    RenderBox? child = firstChild;
    double y = 0;
    var first = true;
    while (child != null) {
      final parentData = child.parentData! as SliverMasonryParentData;
      child.layout(
        constraints.asBoxConstraints(crossAxisExtent: crossExtent),
        parentUsesSize: true,
      );
      if (!first) y += _gap;
      parentData
        ..layoutOffset = y
        ..crossAxisOffset = 0;
      y += _childMainExtent(child);
      first = false;
      child = childAfter(child);
    }

    final paintExtent = calculatePaintOffset(constraints, from: 0, to: y);
    final cacheExtent = calculateCacheOffset(constraints, from: 0, to: y);

    geometry = SliverGeometry(
      scrollExtent: y,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: y,
      hasVisualOverflow: y > constraints.remainingPaintExtent,
    );
  }

  /// Toggle mode: shows only the active zone at full width.
  ///
  /// * `isSideExpanded = true`  → body items render; side items are hidden.
  /// * `isSideExpanded = false` → side items render; body items are hidden.
  /// * [MasonryWidth.full] items always render.
  ///
  /// Used when `bodyMinWidth ≤ crossAxisExtent < bodyMinWidth + sideMinWidth`.
  void _layoutToggle(double crossExtent) {
    RenderBox? child = firstChild;
    double y = 0;
    var first = true;
    var index = 0;
    while (child != null) {
      final parentData = child.parentData! as SliverMasonryParentData;
      final mw = _sizes[index];

      final bool visible = mw == MasonryWidth.full ||
          (mw == MasonryWidth.body && _isSideExpanded) ||
          (mw == MasonryWidth.side && !_isSideExpanded);

      if (visible) {
        child.layout(
          constraints.asBoxConstraints(crossAxisExtent: crossExtent),
          parentUsesSize: true,
        );
        if (!first) y += _gap;
        parentData
          ..layoutOffset = y
          ..crossAxisOffset = 0;
        y += _childMainExtent(child);
        first = false;
      } else {
        // Hidden: zero-sized, off-screen to the right.
        child.layout(
          constraints.asBoxConstraints(crossAxisExtent: 0),
          parentUsesSize: true,
        );
        parentData
          ..layoutOffset = y
          ..crossAxisOffset = crossExtent;
      }

      child = childAfter(child);
      index++;
    }

    final paintExtent = calculatePaintOffset(constraints, from: 0, to: y);
    final cacheExtent = calculateCacheOffset(constraints, from: 0, to: y);

    geometry = SliverGeometry(
      scrollExtent: y,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: y,
      hasVisualOverflow: y > constraints.remainingPaintExtent,
    );
  }

  double _childMainExtent(RenderBox child) {
    return switch (constraints.axis) {
      Axis.horizontal => child.size.width,
      Axis.vertical => child.size.height,
    };
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    final parentData = child.parentData! as SliverMasonryParentData;
    return (parentData.layoutOffset ?? 0) - constraints.scrollOffset;
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    final parentData = child.parentData! as SliverMasonryParentData;
    return parentData.crossAxisOffset;
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    RenderBox? child = lastChild;
    while (child != null) {
      final isHit = hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        child,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
      if (isHit) return true;
      child = childBefore(child);
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    applyPaintTransformForBoxChild(child, transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final mainAxisDelta = childMainAxisPosition(child);
      final childExtent = _childMainExtent(child);
      if (mainAxisDelta < constraints.remainingPaintExtent &&
          mainAxisDelta + childExtent > 0) {
        final childOffset = switch (constraints.axis) {
          Axis.horizontal =>
            Offset(mainAxisDelta, childCrossAxisPosition(child)),
          Axis.vertical =>
            Offset(childCrossAxisPosition(child), mainAxisDelta),
        };
        context.paintChild(child, offset + childOffset);
      }
      child = childAfter(child);
    }
  }
}
