import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'masonry_layout.dart';

/// {@template sliver_masonry_layout}
/// A real-sliver counterpart to [MasonryLayout]: a responsive body/side
/// layout that participates directly in a [CustomScrollView] — no
/// [SliverToBoxAdapter], no nested scrollable.
///
/// Unlike [MasonryLayout], [SliverMasonryLayout] expects its items to
/// produce **Sliver** widgets (e.g. `SliverList`, `SliverGrid`, `SliverToBoxAdapter`).
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

  /// Items to lay out. Each item should produce a **Sliver** widget.
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
      bodyW =
          bodyMaxWidth != null
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
      sideW =
          sideMaxWidth != null
              ? math.min(crossExtent - gap, sideMaxWidth!)
              : crossExtent * 0.3;
      sideW = math.max(sideW, sideMinWidth);
      bodyW = crossExtent - sideW - gap;
    }
    // Fall back to single-column if either zone is below its minimum.
    if (sideW < sideMinWidth || bodyW < bodyMinWidth) return (crossExtent, 0.0);
    return (bodyW, sideW);
  }

  Widget _buildBody(List<Widget> bodySlivers, double bodyW) {
    if (bodySlivers.isEmpty) return const SliverToBoxAdapter();
    final int tracksCount = bodyFactory != null ? bodyFactory!(bodyW) : 1;

    if (tracksCount <= 1) {
      return SliverMainAxisGroup(slivers: bodySlivers);
    }

    // Split into sub-tracks (round-robin)
    final List<List<Widget>> tracks = List.generate(
      tracksCount,
      (_) => <Widget>[],
    );
    for (int i = 0; i < bodySlivers.length; i++) {
      tracks[i % tracksCount].add(bodySlivers[i]);
    }

    final double trackW = (bodyW - gap * (tracksCount - 1)) / tracksCount;
    final List<Widget> trackGroup = [];
    for (int i = 0; i < tracksCount; i++) {
      trackGroup.add(
        SliverConstrainedCrossAxis(
          maxExtent: trackW,
          sliver: SliverMainAxisGroup(slivers: tracks[i]),
        ),
      );
      if (i < tracksCount - 1) {
        trackGroup.add(
          SliverConstrainedCrossAxis(
            maxExtent: gap,
            sliver: const SliverToBoxAdapter(),
          ),
        );
      }
    }
    return SliverCrossAxisGroup(slivers: trackGroup);
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
            (!collapsed && !inToggle)
                ? _zoneWidths(crossExtent)
                : (crossExtent, 0.0);

        // ── Resolve each item ────────────────────────────────────────────
        if (collapsed) {
          final List<Widget> slivers = [];
          for (final item in children) {
            slivers.add(item.resolve(false, crossExtent));
          }
          return SliverMainAxisGroup(slivers: slivers);
        } else if (inToggle) {
          final List<Widget> slivers = [];
          for (final item in children) {
            final bool itemToggle =
                item.width == MasonryWidth.full ||
                (item.width == MasonryWidth.body && isSideExpanded) ||
                (item.width == MasonryWidth.side && !isSideExpanded);
            if (itemToggle) {
              slivers.add(item.resolve(true, crossExtent));
            }
          }
          return SliverMainAxisGroup(slivers: slivers);
        } else {
          // ── Two-column Mode ───────────────────────────────────────────
          final List<Widget> finalSlivers = [];
          List<Widget> currentBody = [];
          List<Widget> currentSide = [];

          void flushColumns() {
            if (currentBody.isEmpty && currentSide.isEmpty) return;

            final Widget bodyWidget = _buildBody(currentBody, bodyW);
            final Widget sideWidget =
                currentSide.isEmpty
                    ? const SliverToBoxAdapter()
                    : SliverMainAxisGroup(slivers: currentSide);

            if (currentBody.isEmpty) {
              finalSlivers.add(
                SliverCrossAxisGroup(
                  slivers: [
                    SliverConstrainedCrossAxis(
                      maxExtent: bodyW + gap,
                      sliver: const SliverToBoxAdapter(),
                    ),
                    SliverConstrainedCrossAxis(
                      maxExtent: sideW,
                      sliver: sideWidget,
                    ),
                  ],
                ),
              );
            } else if (currentSide.isEmpty) {
              finalSlivers.add(
                SliverCrossAxisGroup(
                  slivers: [
                    SliverConstrainedCrossAxis(
                      maxExtent: bodyW,
                      sliver: bodyWidget,
                    ),
                  ],
                ),
              );
            } else {
              finalSlivers.add(
                SliverCrossAxisGroup(
                  slivers: [
                    SliverConstrainedCrossAxis(
                      maxExtent: bodyW,
                      sliver: bodyWidget,
                    ),
                    SliverConstrainedCrossAxis(
                      maxExtent: gap,
                      sliver: const SliverToBoxAdapter(),
                    ),
                    SliverConstrainedCrossAxis(
                      maxExtent: sideW,
                      sliver: sideWidget,
                    ),
                  ],
                ),
              );
            }

            currentBody = [];
            currentSide = [];
          }

          for (final item in children) {
            if (item.width == MasonryWidth.full) {
              flushColumns();
              finalSlivers.add(item.resolve(false, crossExtent));
            } else if (item.width == MasonryWidth.body) {
              currentBody.add(item.resolve(false, bodyW));
            } else if (item.width == MasonryWidth.side) {
              currentSide.add(item.resolve(false, sideW));
            }
          }
          flushColumns();

          return SliverMainAxisGroup(slivers: finalSlivers);
        }
      },
    );
  }
}
