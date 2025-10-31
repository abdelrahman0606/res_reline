import 'package:flutter/rendering.dart';

class SliverGridDelegateWithResponsiveColumns extends SliverGridDelegate {
  final double minColumnWidth;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const SliverGridDelegateWithResponsiveColumns({
    required this.minColumnWidth,
    required this.childAspectRatio,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final availableWidth = constraints.crossAxisExtent;
    final columnsCount = (availableWidth / minColumnWidth).floor();
    final actualColumnsCount = columnsCount < 1 ? 1 : columnsCount;
    final columnWidth =
        (availableWidth - (actualColumnsCount - 1) * crossAxisSpacing) /
            actualColumnsCount;
    final childHeight = columnWidth / childAspectRatio;

    return SliverGridRegularTileLayout(
      crossAxisCount: actualColumnsCount,
      mainAxisStride: childHeight + mainAxisSpacing,
      crossAxisStride: columnWidth + crossAxisSpacing,
      childMainAxisExtent: childHeight,
      childCrossAxisExtent: columnWidth,
      reverseCrossAxis: false,
    );
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) => true;
}