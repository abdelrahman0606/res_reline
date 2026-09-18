part of 'masonry_layout.dart';

/// Parent data for children of [RenderMasonry]. Only the inherited [offset]
/// is needed — every other piece of placement info is transient and lives
/// inside [RenderMasonry.performLayout] instead.
class MasonryParentData extends ContainerBoxParentData<RenderBox> {}

/// The layout engine behind [MasonryLayout].
///
/// Splits the available width into a *body* zone (left) and an optional
/// *side* zone (right). Items declare their target zone via [MasonryWidth]:
///
/// * [MasonryWidth.full] – spans the entire width, resetting both columns.
/// * [MasonryWidth.body] – placed in the body zone.
/// * [MasonryWidth.side] – placed in the side zone; falls back to body when
///   the side zone is unavailable.
///
/// **Width thresholds & layout modes**
///
/// | Available width                        | Mode          |
/// |----------------------------------------|---------------|
/// | `< bodyMinWidth`                       | collapsed     |
/// | `bodyMinWidth … bodyMinWidth+sideMinWidth` | toggle    |
/// | `≥ bodyMinWidth + sideMinWidth`        | two-column    |
///
/// * **Collapsed** — all items stack in a single full-width column.
/// * **Toggle** — only one zone is shown at full width:
///   * `isSideExpanded = true`  → body items at full width; side items hidden.
///   * `isSideExpanded = false` → side items at full width; body items hidden.
///   * `full` items always render in both toggle states.
/// * **Two-column** — normal body + side layout governed by [bodyMaxWidth],
///   [sideMaxWidth], and [isSideExpanded].
///
/// **Body sub-tracks**
/// Optionally, `bodyFactory` may return a track count > 1 for a given body
/// width, causing body items to be masonry-packed across that many equal
/// sub-tracks within the body zone.
class RenderMasonry extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MasonryParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MasonryParentData> {
  RenderMasonry({
    required List<MasonryWidth> widths,
    required double gap,
    required double bodyMinWidth,
    required double sideMinWidth,
    double? bodyMaxWidth,
    double? sideMaxWidth,
    required bool isSideExpanded,
    int Function(double)? bodyFactory,
  })  : _widths = widths,
        _gap = gap,
        _bodyMinWidth = bodyMinWidth,
        _sideMinWidth = sideMinWidth,
        _bodyMaxWidth = bodyMaxWidth,
        _sideMaxWidth = sideMaxWidth,
        _isSideExpanded = isSideExpanded,
        _bodyFactory = bodyFactory;

  // ── Fields ──────────────────────────────────────────────────────────────

  List<MasonryWidth> _widths;
  List<MasonryWidth> get widths => _widths;
  set widths(List<MasonryWidth> value) {
    if (_widths == value) return;
    _widths = value;
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

  /// Below this width the layout collapses to a single full-width column.
  double get bodyMinWidth => _bodyMinWidth;
  set bodyMinWidth(double value) {
    if (_bodyMinWidth == value) return;
    _bodyMinWidth = value;
    markNeedsLayout();
  }

  double _sideMinWidth;

  /// Minimum usable width for the side zone.
  ///
  /// When `availableWidth < bodyMinWidth + sideMinWidth` the layout enters
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
  /// `true`). When `null` the body zone consumes all available width.
  double? get bodyMaxWidth => _bodyMaxWidth;
  set bodyMaxWidth(double? value) {
    if (_bodyMaxWidth == value) return;
    _bodyMaxWidth = value;
    markNeedsLayout();
  }

  double? _sideMaxWidth;

  /// Maximum pixel width of the side zone (used when [isSideExpanded] is
  /// `false`). When `null` the side zone defaults to 30 % of available width.
  double? get sideMaxWidth => _sideMaxWidth;
  set sideMaxWidth(double? value) {
    if (_sideMaxWidth == value) return;
    _sideMaxWidth = value;
    markNeedsLayout();
  }

  bool _isSideExpanded;

  /// `true`  → body zone is dominant (limited by [bodyMaxWidth]).
  /// `false` → side zone uses its preferred width ([sideMaxWidth]).
  bool get isSideExpanded => _isSideExpanded;
  set isSideExpanded(bool value) {
    if (_isSideExpanded == value) return;
    _isSideExpanded = value;
    markNeedsLayout();
  }

  int Function(double)? _bodyFactory;

  /// Optional callback that receives the body zone width and returns how many
  /// equal sub-tracks the body zone should be divided into. Body items are
  /// then masonry-packed across those sub-tracks. When `null` the body zone
  /// is treated as a single column.
  int Function(double)? get bodyFactory => _bodyFactory;
  set bodyFactory(int Function(double)? value) {
    if (_bodyFactory == value) return;
    _bodyFactory = value;
    markNeedsLayout();
  }

  // ── RenderBox overrides ─────────────────────────────────────────────────

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MasonryParentData) {
      child.parentData = MasonryParentData();
    }
  }

  @override
  void performLayout() {
    assert(
      constraints.hasBoundedWidth,
      'RenderMasonry needs a bounded width to lay out its children. Wrap it '
      'in a SizedBox, Expanded, or another ancestor that provides a finite '
      'width.',
    );

    if (childCount == 0 || !constraints.hasBoundedWidth) {
      size = constraints.constrain(Size(
        constraints.hasBoundedWidth ? constraints.maxWidth : 0,
        0,
      ));
      return;
    }

    final totalWidth = constraints.maxWidth;

    // Below bodyMinWidth collapse everything to a single full-width column.
    if (totalWidth < _bodyMinWidth) {
      _layoutCollapsed(totalWidth);
      return;
    }

    // In the range [bodyMinWidth, bodyMinWidth + sideMinWidth) the screen is
    // wide enough for one zone but not both — enter toggle mode.
    if (totalWidth < _bodyMinWidth + _sideMinWidth) {
      _layoutToggle(totalWidth);
      return;
    }

    // ── Compute zone widths ────────────────────────────────────────────
    double bodyW, sideW;
    if (_isSideExpanded) {
      // Body dominant: grow body up to bodyMaxWidth, then give remainder to side.
      bodyW = _bodyMaxWidth != null
          ? math.min(totalWidth, _bodyMaxWidth!)
          : totalWidth;
      sideW = totalWidth - bodyW - _gap;
      // Ensure side meets its minimum — steal from body if necessary.
      if (sideW < _sideMinWidth) {
        sideW = _sideMinWidth;
        bodyW = totalWidth - sideW - _gap;
      }
    } else {
      // Side gets its preferred width, floored at sideMinWidth.
      sideW = _sideMaxWidth != null
          ? math.min(totalWidth - _gap, _sideMaxWidth!)
          : totalWidth * 0.3;
      sideW = math.max(sideW, _sideMinWidth);
      bodyW = totalWidth - sideW - _gap;
    }

    // Fall back to body-only if either zone is below its minimum.
    final bool activeSide = sideW >= _sideMinWidth && bodyW >= _bodyMinWidth;
    if (!activeSide) {
      bodyW = totalWidth;
      sideW = 0.0;
    }

    // ── Body sub-tracks (via bodyFactory) ────────────────────────────────
    final int bodySubTracks =
        _bodyFactory != null ? _bodyFactory!(bodyW).clamp(1, 8) : 1;
    final double bodySubTrackW = bodySubTracks > 1
        ? (bodyW - _gap * (bodySubTracks - 1)) / bodySubTracks
        : bodyW;

    // ── Track table ───────────────────────────────────────────────────────
    // Indices 0..(bodySubTracks-1) = body sub-tracks.
    // Index bodySubTracks           = side track (only when activeSide).
    final int totalTracks = bodySubTracks + (activeSide ? 1 : 0);
    final trackHeights = List<double>.filled(totalTracks, 0.0);
    final trackX = <double>[
      for (var t = 0; t < bodySubTracks; t++) t * (bodySubTrackW + _gap),
      if (activeSide) bodyW + _gap,
    ];

    // ── Place children ────────────────────────────────────────────────────
    RenderBox? child = firstChild;
    var index = 0;
    while (child != null) {
      final parentData = child.parentData! as MasonryParentData;
      final mw = _widths[index];

      double itemWidth;
      double xOffset;
      double yOffset;

      if (mw == MasonryWidth.full) {
        // ── full: spans everything ────────────────────────────────────────
        final zoneH = trackHeights.reduce(math.max);
        xOffset = 0;
        yOffset = zoneH == 0 ? 0 : zoneH + _gap;
        itemWidth = totalWidth;

        child.layout(
          BoxConstraints(
            minWidth: itemWidth,
            maxWidth: itemWidth,
            maxHeight: double.infinity,
          ),
          parentUsesSize: true,
        );
        final newH = yOffset + child.size.height;
        for (var t = 0; t < totalTracks; t++) {
          trackHeights[t] = newH;
        }
      } else if (mw == MasonryWidth.body) {
        // ── body: masonry-pack within body sub-tracks ─────────────────────
        var bestT = 0;
        for (var t = 1; t < bodySubTracks; t++) {
          if (trackHeights[t] < trackHeights[bestT]) bestT = t;
        }
        final bestH = trackHeights[bestT];
        xOffset = trackX[bestT];
        yOffset = bestH == 0 ? 0 : bestH + _gap;
        itemWidth = bodySubTrackW;

        child.layout(
          BoxConstraints(
            minWidth: itemWidth,
            maxWidth: itemWidth,
            maxHeight: double.infinity,
          ),
          parentUsesSize: true,
        );
        trackHeights[bestT] = yOffset + child.size.height;
      } else {
        // ── side: placed in the side zone ────────────────────────────────
        if (activeSide) {
          final sideTrackIdx = bodySubTracks;
          final sideH = trackHeights[sideTrackIdx];
          xOffset = trackX[sideTrackIdx];
          yOffset = sideH == 0 ? 0 : sideH + _gap;
          itemWidth = sideW;

          child.layout(
            BoxConstraints(
              minWidth: itemWidth,
              maxWidth: itemWidth,
              maxHeight: double.infinity,
            ),
            parentUsesSize: true,
          );
          trackHeights[sideTrackIdx] = yOffset + child.size.height;
        } else {
          // Side zone collapsed → fall back to body zone placement.
          var bestT = 0;
          for (var t = 1; t < bodySubTracks; t++) {
            if (trackHeights[t] < trackHeights[bestT]) bestT = t;
          }
          final bestH = trackHeights[bestT];
          xOffset = trackX[bestT];
          yOffset = bestH == 0 ? 0 : bestH + _gap;
          itemWidth = bodySubTrackW;

          child.layout(
            BoxConstraints(
              minWidth: itemWidth,
              maxWidth: itemWidth,
              maxHeight: double.infinity,
            ),
            parentUsesSize: true,
          );
          trackHeights[bestT] = yOffset + child.size.height;
        }
      }

      parentData.offset = Offset(xOffset, yOffset);
      child = parentData.nextSibling;
      index++;
    }

    final totalHeight = trackHeights.isEmpty ? 0.0 : trackHeights.reduce(math.max);
    size = constraints.constrain(Size(totalWidth, totalHeight));
  }

  /// Lays out all children in a single full-width column.
  ///
  /// Used when the available width is below [bodyMinWidth].
  void _layoutCollapsed(double width) {
    RenderBox? child = firstChild;
    double y = 0;
    var first = true;
    while (child != null) {
      final parentData = child.parentData! as MasonryParentData;
      child.layout(
        BoxConstraints(
          minWidth: width,
          maxWidth: width,
          maxHeight: double.infinity,
        ),
        parentUsesSize: true,
      );
      if (!first) y += _gap;
      parentData.offset = Offset(0, y);
      y += child.size.height;
      first = false;
      child = parentData.nextSibling;
    }
    size = constraints.constrain(Size(width, y));
  }

  /// Toggle mode: shows only the active zone at full width.
  ///
  /// * `isSideExpanded = true`  → body items render; side items are skipped.
  /// * `isSideExpanded = false` → side items render; body items are skipped.
  /// * [MasonryWidth.full] items always render.
  ///
  /// Used when `bodyMinWidth ≤ availableWidth < bodyMinWidth + sideMinWidth`.
  void _layoutToggle(double width) {
    RenderBox? child = firstChild;
    double y = 0;
    var first = true;
    var index = 0;
    while (child != null) {
      final parentData = child.parentData! as MasonryParentData;
      final mw = _widths[index];

      // Determine whether this item is visible in the current toggle state.
      final bool visible = mw == MasonryWidth.full ||
          (mw == MasonryWidth.body && _isSideExpanded) ||
          (mw == MasonryWidth.side && !_isSideExpanded);

      if (visible) {
        child.layout(
          BoxConstraints(
            minWidth: width,
            maxWidth: width,
            maxHeight: double.infinity,
          ),
          parentUsesSize: true,
        );
        if (!first) y += _gap;
        parentData.offset = Offset(0, y);
        y += child.size.height;
        first = false;
      } else {
        // Hidden item: give it zero size and push it off-screen.
        child.layout(
          BoxConstraints.tight(Size.zero),
          parentUsesSize: true,
        );
        parentData.offset = Offset(width, y); // off-screen to the right
      }

      child = parentData.nextSibling;
      index++;
    }
    size = constraints.constrain(Size(width, y));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
