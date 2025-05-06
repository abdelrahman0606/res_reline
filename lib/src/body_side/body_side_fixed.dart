import 'package:flutter/material.dart';

import 'separate_widget.dart';
import 'side_widget.dart';
part 'body_side_fixed_state.dart';
class ResBodySideFixed<T> extends StatefulWidget {
  final double defaultBodyWidth;
  final Widget? body;
  final Widget? side;
  final int? itemCount;
  final ScrollPhysics? physics;
  final Widget Function(
    BuildContext,
    int index,
   void Function(int selectIndex, {T? model, bool refresh}) onSelect,
  )? bodyBuilder;
  final Function(BuildContext context, int index, T? model)? sideBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool isSelector;
  final double minBodyFactor;
  final double minBodyWidth;
  final double minSideFactor;
  final Function(bool isMobile, int index)? onSelect;
  final Function()? onClose;
  final bool hideBody;
  final bool hideSide;
  final Widget slideWidget;
  final double minSideWidth;
  final double maxSideWidth;
  final double topPosition;
  final int initSelectedIndex;
  final T Function(int index)? initSelectedModel;

  const ResBodySideFixed({
    super.key,
    required this.body,
    required this.side,
    this.initSelectedModel,
    this.initSelectedIndex = -1,
    this.defaultBodyWidth = 0.7,
    this.minBodyFactor = 0.3,
    this.minBodyWidth = 300,
    this.minSideFactor = 0.3,
    this.minSideWidth = 0,
    this.maxSideWidth = 500,
    this.topPosition = 10,
    this.hideBody = false,
    this.hideSide = false,
    this.onClose,
    this.slideWidget = const SeparateWidget(),
  })  : bodyBuilder = null,
        separatorBuilder = null,
        isSelector = false,
        sideBuilder = null,
        physics = null,
        itemCount = null,
        onSelect = null;

  const ResBodySideFixed.selector({
    super.key,
    required this.bodyBuilder,
    this.sideBuilder,
    this.initSelectedModel,
    this.initSelectedIndex = -1,
    this.defaultBodyWidth = 0.3,
    this.hideBody = false,
    this.hideSide = false,
    this.minBodyFactor = 0.3,
    this.minBodyWidth = 400,
    this.minSideFactor = 0.3,
    this.minSideWidth = 0,
    this.maxSideWidth = 500,
    this.topPosition = 10,
    this.onClose,
    this.slideWidget = const SeparateWidget(),
  })  : body = null,
        side = null,
        physics = null,
        onSelect = null,
        itemCount = null,
        separatorBuilder = null,
        isSelector = true;

  @override
  State<ResBodySideFixed> createState() => _ResBodySideFixedState<T>();
}

