import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ResponsiveSliverGridDelegate extends SliverGridDelegate {
  const ResponsiveSliverGridDelegate({
    required this.minItemWidth,
    required this.maxItemWidth,
    required this.itemHeight,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.lastItemTakesRemainingWidth = false,
    this.itemCount,
  });

  final double minItemWidth;
  final double maxItemWidth;
  final double itemHeight;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool lastItemTakesRemainingWidth;
  final int? itemCount;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    int crossAxisCount = (constraints.crossAxisExtent + crossAxisSpacing) ~/ (minItemWidth + crossAxisSpacing);
    if (crossAxisCount == 0) {
      crossAxisCount = 1;
    }

    double usableCrossAxisExtent = constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;

    if (childCrossAxisExtent > maxItemWidth) {
      crossAxisCount = (constraints.crossAxisExtent + crossAxisSpacing) ~/ (maxItemWidth + crossAxisSpacing) + 1;
      usableCrossAxisExtent = constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
      childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    }

    return _ResponsiveSliverGridLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: itemHeight + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: itemHeight,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
      itemCount: itemCount,
      lastItemTakesRemainingWidth: lastItemTakesRemainingWidth,
    );
  }

  @override
  bool shouldRelayout(ResponsiveSliverGridDelegate oldDelegate) {
    return oldDelegate.minItemWidth != minItemWidth ||
           oldDelegate.maxItemWidth != maxItemWidth ||
           oldDelegate.itemHeight != itemHeight ||
           oldDelegate.mainAxisSpacing != mainAxisSpacing ||
           oldDelegate.crossAxisSpacing != crossAxisSpacing ||
           oldDelegate.lastItemTakesRemainingWidth != lastItemTakesRemainingWidth ||
           oldDelegate.itemCount != itemCount;
  }
}

class _ResponsiveSliverGridLayout extends SliverGridRegularTileLayout {
  const _ResponsiveSliverGridLayout({
    required super.crossAxisCount,
    required super.mainAxisStride,
    required super.crossAxisStride,
    required super.childMainAxisExtent,
    required super.childCrossAxisExtent,
    required super.reverseCrossAxis,
    this.itemCount,
    this.lastItemTakesRemainingWidth = false,
  });

  final int? itemCount;
  final bool lastItemTakesRemainingWidth;

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    if (lastItemTakesRemainingWidth && itemCount != null && index == itemCount! - 1) {
      final int column = index % crossAxisCount;
      final int columnsRemaining = crossAxisCount - column;
      if (columnsRemaining > 1) {
        final double extendedCrossAxisExtent = childCrossAxisExtent + (columnsRemaining - 1) * crossAxisStride;
        final regularGeo = super.getGeometryForChildIndex(index);
        return SliverGridGeometry(
          scrollOffset: regularGeo.scrollOffset,
          crossAxisOffset: regularGeo.crossAxisOffset,
          mainAxisExtent: regularGeo.mainAxisExtent,
          crossAxisExtent: extendedCrossAxisExtent,
        );
      }
    }
    return super.getGeometryForChildIndex(index);
  }
}


class SliverGridDelegateWithMinMaxCrossAxisExtent extends SliverGridDelegate {
  /// The smallest a tile's width is allowed to be. Determines the max
  /// number of columns on small/medium screens.
  final double minItemWidth;

  /// The largest a tile's width is allowed to be. Determines the min
  /// number of columns on large screens (keeps tiles from growing huge).
  final double maxItemWidth;

  /// width / height of each tile. Ignored if [childAspectRatioOne] is set
  /// and the grid ends up with exactly 1 column.
  final double childAspectRatio;

  /// Optional different aspect ratio to use only when there's a single
  /// column (handy for making a lone full-width card look less stretched).
  final double? childAspectRatioOne;

  final double crossAxisSpacing;
  final double mainAxisSpacing;

  /// Fired every time a layout pass computes the column count, so you can
  /// react to it outside the grid (e.g. update some other UI).
  final void Function(int crossAxisCount, double itemWidth, double itemHeight)?
  onLayoutChanged;

  const SliverGridDelegateWithMinMaxCrossAxisExtent({
    required this.minItemWidth,
    required this.maxItemWidth,
    this.childAspectRatio = 1.0,
    this.childAspectRatioOne,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.onLayoutChanged,
  })  : assert(minItemWidth > 0),
        assert(maxItemWidth > 0),
        assert(maxItemWidth >= minItemWidth,
        'maxItemWidth must be >= minItemWidth');

  double _columnWidthFor(int count, double availableWidth) {
    return (availableWidth - (count - 1) * crossAxisSpacing) / count;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double availableWidth = constraints.crossAxisExtent;

    // Step 1: as many columns as possible while each stays >= minItemWidth.
    int crossAxisCount =
    ((availableWidth + crossAxisSpacing) / (minItemWidth + crossAxisSpacing))
        .floor();
    if (crossAxisCount < 1) crossAxisCount = 1;

    double columnWidth = _columnWidthFor(crossAxisCount, availableWidth);

    // Step 2: if that's still wider than allowed (e.g. minItemWidth is
    // large relative to the screen so we only got 1-2 columns), keep
    // adding columns until we respect maxItemWidth too.
    // The 100 cap is just a sane safety valve against an infinite loop.
    while (columnWidth > maxItemWidth && crossAxisCount < 100) {
      crossAxisCount++;
      columnWidth = _columnWidthFor(crossAxisCount, availableWidth);
    }

    // Safety net for pathological cases (e.g. availableWidth is 0 or
    // spacing alone exceeds the available width).
    if (columnWidth <= 0 || columnWidth.isNaN) {
      crossAxisCount = 1;
      columnWidth = availableWidth > 0 ? availableWidth : 1;
    }

    final double aspectRatio = crossAxisCount == 1
        ? (childAspectRatioOne ?? childAspectRatio)
        : childAspectRatio;
    final double childHeight = columnWidth / aspectRatio;

    onLayoutChanged?.call(crossAxisCount, columnWidth, childHeight);

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childHeight + mainAxisSpacing,
      crossAxisStride: columnWidth + crossAxisSpacing,
      childMainAxisExtent: childHeight,
      childCrossAxisExtent: columnWidth,
      reverseCrossAxis: false,
    );
  }

  @override
  bool shouldRelayout(
      covariant SliverGridDelegateWithMinMaxCrossAxisExtent oldDelegate) {
    return oldDelegate.minItemWidth != minItemWidth ||
        oldDelegate.maxItemWidth != maxItemWidth ||
        oldDelegate.childAspectRatio != childAspectRatio ||
        oldDelegate.childAspectRatioOne != childAspectRatioOne ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing;
  }
}