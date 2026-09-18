import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
part 'masonry_item.dart';
part 'masonry_width.dart';
part 'render_masonry.dart';

/// {@template Masonry}
/// A responsive body/side layout that uses masonry-style packing within each
/// zone.
///
/// Items declare *what* to show and *which zone* each one belongs to as a list
/// of [MasonryItem]s:
///
/// * [MasonryWidth.full]  – spans the entire available width.
/// * [MasonryWidth.body]  – placed in the dominant body column.
/// * [MasonryWidth.side]  – placed in the narrower side column.
///
/// `MasonryLayout` decides how to arrange them for whatever width it is given.
/// Three layout modes are applied automatically based on the available width:
///
/// | Available width                              | Mode        |
/// |----------------------------------------------|-------------|
/// | `< bodyMinWidth`                             | collapsed   |
/// | `bodyMinWidth … bodyMinWidth + sideMinWidth` | toggle      |
/// | `≥ bodyMinWidth + sideMinWidth`              | two-column  |
///
/// In **toggle mode** only the active zone is shown at full width:
/// * `isSideExpanded = true`  → body items visible; side items hidden.
/// * `isSideExpanded = false` → side items visible; body items hidden.
/// * [MasonryWidth.full] items always render in any mode.
///
/// Items may provide a [MasonryItem.builder] to react to the current
/// `toggle` state and the `maxWidth` they have been allocated.
///
/// ```dart
/// MasonryLayout(
///   gap: 12,
///   bodyMinWidth: 700,
///   sideMinWidth: 280,
///   bodyMaxWidth: 900,
///   sideMaxWidth: 320,
///   isSideExpanded: false,
///   children: [
///     MasonryItem(child: Header(), width: MasonryWidth.full),
///     MasonryItem(
///       width: MasonryWidth.body,
///       builder: (toggle, maxWidth) => Feed(compact: toggle),
///     ),
///     MasonryItem(child: Panel(), width: MasonryWidth.side),
///   ],
/// )
/// ```
/// {@endtemplate}
class MasonryLayout extends StatelessWidget {
  /// {@macro Masonry}
  const MasonryLayout({
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

  /// Spacing applied both between body/side zones and between items stacked
  /// within each zone. Defaults to 8 logical pixels.
  final double gap;

  /// Available width below which the layout collapses to a single full-width
  /// column. Defaults to 600 logical pixels.
  final double bodyMinWidth;

  /// Minimum usable width for the side zone.
  ///
  /// When `availableWidth < bodyMinWidth + sideMinWidth` the layout enters
  /// **toggle mode** — only the active zone is shown at full width. Defaults
  /// to 300 logical pixels.
  final double sideMinWidth;

  /// Maximum pixel width of the body zone.
  ///
  /// Respected when [isSideExpanded] is `true`. `null` → body fills all
  /// available width.
  final double? bodyMaxWidth;

  /// Maximum pixel width of the side zone.
  ///
  /// Respected when [isSideExpanded] is `false`. `null` → side defaults to
  /// 30 % of available width.
  final double? sideMaxWidth;

  /// Controls which zone is dominant.
  ///
  /// * `true`  → body zone expands up to [bodyMaxWidth]; side fills the rest.
  /// * `false` → side zone uses [sideMaxWidth]; body fills the rest.
  final bool isSideExpanded;

  /// Optional factory that receives the body zone's pixel width and returns
  /// how many equal sub-tracks the body should be split into. Body items are
  /// then masonry-packed across those sub-tracks. `null` → single column.
  final int Function(double bodyWidth)? bodyFactory;

  // ── Width helpers ────────────────────────────────────────────────────────

  /// Computes body and side zone widths for [totalWidth] in two-column mode.
  /// The side zone is always at least [sideMinWidth] wide.
  (double bodyW, double sideW) _zoneWidths(double totalWidth) {
    double bodyW, sideW;
    if (isSideExpanded) {
      // Body dominant: grow body up to bodyMaxWidth, then give remainder to side.
      bodyW = bodyMaxWidth != null
          ? math.min(totalWidth, bodyMaxWidth!)
          : totalWidth;
      sideW = totalWidth - bodyW - gap;
      // Ensure side meets its minimum — steal from body if necessary.
      if (sideW < sideMinWidth) {
        sideW = sideMinWidth;
        bodyW = totalWidth - sideW - gap;
      }
    } else {
      // Side gets its preferred width, floored at sideMinWidth.
      sideW = sideMaxWidth != null
          ? math.min(totalWidth - gap, sideMaxWidth!)
          : totalWidth * 0.3;
      sideW = math.max(sideW, sideMinWidth);
      bodyW = totalWidth - sideW - gap;
    }
    // Fall back to single-column if either zone is below its minimum.
    if (sideW < sideMinWidth || bodyW < bodyMinWidth) return (totalWidth, 0.0);
    return (bodyW, sideW);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        // ── Determine mode ──────────────────────────────────────────────
        final bool collapsed = totalWidth < bodyMinWidth;
        final bool inToggle =
            !collapsed && totalWidth < bodyMinWidth + sideMinWidth;

        // ── Zone widths (only needed in two-column mode) ─────────────────
        final (double bodyW, double sideW) =
            (!collapsed && !inToggle) ? _zoneWidths(totalWidth) : (totalWidth, 0.0);

        // ── Resolve each item ────────────────────────────────────────────
        final builtChildren = <Widget>[];
        for (final item in children) {
          final double itemWidth;
          final bool itemToggle;

          if (collapsed) {
            itemWidth = totalWidth;
            itemToggle = false;
          } else if (inToggle) {
            // Toggle mode: item gets full width; toggle flag = active zone.
            itemWidth = totalWidth;
            itemToggle = item.width == MasonryWidth.full ||
                (item.width == MasonryWidth.body && isSideExpanded) ||
                (item.width == MasonryWidth.side && !isSideExpanded);
          } else {
            // Two-column mode.
            itemToggle = false;
            itemWidth = switch (item.width) {
              MasonryWidth.full => totalWidth,
              MasonryWidth.body => bodyW,
              MasonryWidth.side => sideW > 0 ? sideW : bodyW,
            };
          }

          builtChildren.add(item.resolve(itemToggle, itemWidth));
        }

        return _MasonryLayoutImpl(
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

/// The internal [MultiChildRenderObjectWidget] powering [MasonryLayout].
///
/// Prefer [MasonryLayout] directly — it resolves [MasonryItem.builder] items
/// and computes toggle context before handing widgets to this layer.
class _MasonryLayoutImpl extends MultiChildRenderObjectWidget {
  _MasonryLayoutImpl({
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
  RenderMasonry createRenderObject(BuildContext context) {
    return RenderMasonry(
      widths: _widths,
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
  void updateRenderObject(BuildContext context, RenderMasonry renderObject) {
    renderObject
      ..widths = _widths
      ..gap = gap
      ..bodyMinWidth = bodyMinWidth
      ..sideMinWidth = sideMinWidth
      ..bodyMaxWidth = bodyMaxWidth
      ..sideMaxWidth = sideMaxWidth
      ..isSideExpanded = isSideExpanded
      ..bodyFactory = bodyFactory;
  }
}
