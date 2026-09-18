import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'masonry_layout.dart';
part 'render_sliver_masonry_layout.dart';

/// {@template sliver_masonry_layout}
/// A real-sliver counterpart to [MasonryLayout]: a responsive body/side
/// layout that participates directly in a [CustomScrollView] — no
/// [SliverToBoxAdapter], no nested scrollable.
///
/// The same three-mode model as [MasonryLayout] applies:
///
/// | Cross-axis extent                            | Mode        |
/// |----------------------------------------------|-------------|
/// | `< bodyMinWidth`                             | collapsed   |
/// | `bodyMinWidth … bodyMinWidth + sideMinWidth` | toggle      |
/// | `≥ bodyMinWidth + sideMinWidth`              | two-column  |
///
/// Items may provide a [MasonryItem.builder] to react to the current
/// `toggle` state and the `maxWidth` they have been allocated.
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverMasonryLayout(
///       gap: 12,
///       bodyMinWidth: 700,
///       sideMinWidth: 280,
///       bodyMaxWidth: 900,
///       sideMaxWidth: 320,
///       isSideExpanded: false,
///       children: [
///         MasonryItem(child: Header(), width: MasonryWidth.full),
///         MasonryItem(
///           width: MasonryWidth.body,
///           builder: (toggle, maxWidth) => Feed(compact: toggle),
///         ),
///         MasonryItem(child: Panel(), width: MasonryWidth.side),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// See [RenderSliverMasonryLayout] for implementation notes on why all
/// children are laid out on every pass rather than virtualized.
/// {@endtemplate}
class SliverMasonryLayout extends StatelessWidget {
  /// {@macro sliver_masonry_layout}
  const SliverMasonryLayout({
    super.key,
    required this.children,
    this.gap = 8,
    this.bodyMinWidth = 600,
    this.sideMinWidth = 300,
    this.bodyMaxWidth,
    this.sideMaxWidth,
    this.isSideExpanded = false,
    this.bodyFactory,
  });

  /// Items to lay out.
  final List<MasonryItem> children;

  /// Spacing applied between zones and between items within each zone.
  /// Defaults to 8 logical pixels.
  final double gap;

  /// Cross-axis extent below which the layout collapses to a single
  /// full-width column. Defaults to 600 logical pixels.
  final double bodyMinWidth;

  /// Minimum usable width for the side zone.
  ///
  /// When `crossAxisExtent < bodyMinWidth + sideMinWidth` the layout enters
  /// **toggle mode**. Defaults to 300 logical pixels.
  final double sideMinWidth;

  /// Maximum pixel width of the body zone (used when [isSideExpanded] is
  /// `true`). `null` → body fills all available extent.
  final double? bodyMaxWidth;

  /// Maximum pixel width of the side zone (used when [isSideExpanded] is
  /// `false`). `null` → 30 % of available extent.
  final double? sideMaxWidth;

  /// Controls which zone is dominant.
  ///
  /// * `true`  → body zone expands up to [bodyMaxWidth].
  /// * `false` → side zone uses [sideMaxWidth]; body fills the rest.
  final bool isSideExpanded;

  /// Optional factory that receives the body zone width and returns how many
  /// equal sub-tracks the body should be split into. `null` → single column.
  final int Function(double bodyWidth)? bodyFactory;

  // ── Width helpers ────────────────────────────────────────────────────────

  /// The side zone is always at least [sideMinWidth] wide.
  (double bodyW, double sideW) _zoneWidths(double crossExtent) {
    double bodyW, sideW;
    if (isSideExpanded) {
      // Body dominant: grow body up to bodyMaxWidth, then give remainder to side.
      bodyW = bodyMaxWidth != null
          ? math.min(crossExtent, bodyMaxWidth!)
          : crossExtent;
      sideW = crossExtent - bodyW - gap;
      // Ensure side meets its minimum — steal from body if necessary.
      if (sideW < sideMinWidth) {
        sideW = sideMinWidth;
        bodyW = crossExtent - sideW - gap;
      }
    } else {
      // Side gets its preferred width, floored at sideMinWidth.
      sideW = sideMaxWidth != null
          ? math.min(crossExtent - gap, sideMaxWidth!)
          : crossExtent * 0.3;
      sideW = math.max(sideW, sideMinWidth);
      bodyW = crossExtent - sideW - gap;
    }
    // Fall back to single-column if either zone is below its minimum.
    if (sideW < sideMinWidth || bodyW < bodyMinWidth) return (crossExtent, 0.0);
    return (bodyW, sideW);
  }

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossExtent = constraints.crossAxisExtent;

        // ── Determine mode ──────────────────────────────────────────────
        final bool collapsed = crossExtent < bodyMinWidth;
        final bool inToggle =
            !collapsed && crossExtent < bodyMinWidth + sideMinWidth;

        // ── Zone widths ─────────────────────────────────────────────────
        final (double bodyW, double sideW) =
            (!collapsed && !inToggle) ? _zoneWidths(crossExtent) : (crossExtent, 0.0);

        // ── Resolve each item ────────────────────────────────────────────
        final builtChildren = <Widget>[];
        for (final item in children) {
          final double itemWidth;
          final bool itemToggle;

          if (collapsed) {
            itemWidth = crossExtent;
            itemToggle = false;
          } else if (inToggle) {
            itemWidth = crossExtent;
            itemToggle = item.width == MasonryWidth.full ||
                (item.width == MasonryWidth.body && isSideExpanded) ||
                (item.width == MasonryWidth.side && !isSideExpanded);
          } else {
            itemToggle = false;
            itemWidth = switch (item.width) {
              MasonryWidth.full => crossExtent,
              MasonryWidth.body => bodyW,
              MasonryWidth.side => sideW > 0 ? sideW : bodyW,
            };
          }

          builtChildren.add(item.resolve(itemToggle, itemWidth));
        }

        return _SliverMasonryLayoutImpl(
          widths: children.map((e) => e.width).toList(growable: false),
          gap: gap,
          bodyMinWidth: bodyMinWidth,
          sideMinWidth: sideMinWidth,
          bodyMaxWidth: bodyMaxWidth,
          sideMaxWidth: sideMaxWidth,
          isSideExpanded: isSideExpanded,
          bodyFactory: bodyFactory,
          children: builtChildren,
        );
      },
    );
  }
}

// ── Internal render-object widget ────────────────────────────────────────────

/// The internal [MultiChildRenderObjectWidget] powering [SliverMasonryLayout].
///
/// Prefer [SliverMasonryLayout] directly.
class _SliverMasonryLayoutImpl extends MultiChildRenderObjectWidget {
  _SliverMasonryLayoutImpl({
    required List<MasonryWidth> widths,
    required this.gap,
    required this.bodyMinWidth,
    required this.sideMinWidth,
    this.bodyMaxWidth,
    this.sideMaxWidth,
    required this.isSideExpanded,
    this.bodyFactory,
    required super.children,
  }) : _widths = List<MasonryWidth>.unmodifiable(widths);

  final double gap;
  final double bodyMinWidth;
  final double sideMinWidth;
  final double? bodyMaxWidth;
  final double? sideMaxWidth;
  final bool isSideExpanded;
  final int Function(double)? bodyFactory;
  final List<MasonryWidth> _widths;

  @override
  RenderSliverMasonryLayout createRenderObject(BuildContext context) {
    return RenderSliverMasonryLayout(
      sizes: _widths,
      gap: gap,
      bodyMinWidth: bodyMinWidth,
      sideMinWidth: sideMinWidth,
      bodyMaxWidth: bodyMaxWidth,
      sideMaxWidth: sideMaxWidth,
      isSideExpanded: isSideExpanded,
      bodyFactory: bodyFactory,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverMasonryLayout renderObject,
  ) {
    renderObject
      ..sizes = _widths
      ..gap = gap
      ..bodyMinWidth = bodyMinWidth
      ..sideMinWidth = sideMinWidth
      ..bodyMaxWidth = bodyMaxWidth
      ..sideMaxWidth = sideMaxWidth
      ..isSideExpanded = isSideExpanded
      ..bodyFactory = bodyFactory;
  }
}
