import 'dart:math';

import 'package:flutter/material.dart';

import 'separate_widget.dart';
import 'side_widget.dart';
part 'body_side_fixed_state.dart';
class ResBodySideFixed<T> extends StatefulWidget {
  final double defaultBodyWidth;
  final Widget? body;
  final Widget? side;
  final Widget? sideEmptyWidget;
  final int? itemCount;
  final ScrollPhysics? physics;
  final Widget Function(
    BuildContext,
    int index,
   void Function(int selectIndex, {T? model, bool refresh}) onSelect,
  )? bodyBuilder;
  final Widget Function(BuildContext context, int index, T? model, void Function() onBack, bool canBack)? sideBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool isSelector;
  final double? minBodyFactor;
  final double minBodyWidth;
  final double? maxBodyWidth;
  final double minSideFactor;
  final Function(bool isMobile, int index)? onSelect;
  final Function()? onClose;
  final bool hideBody;
  final bool hideSide;
  final bool enableFullScreenIcon;
  final Widget slideWidget;
  final double minSideWidth;
  final double? maxSideWidth;
  final double topPosition;
  final double slideWidth;
  final int initSelectedIndex;
  final T Function(int index)? initSelectedModel;

  const ResBodySideFixed({
    super.key,
    required this.body,
    required this.side,
     this.sideEmptyWidget,
    this.initSelectedModel,
    this.initSelectedIndex = -1,
    this.defaultBodyWidth = 0.7,
    this.minBodyFactor,
    this.minBodyWidth = 300,
    this.maxBodyWidth,
    this.minSideFactor = 0.3,
    this.minSideWidth = 0,
    this.maxSideWidth ,
    this.slideWidth = 15,
    this.topPosition = 10,
    this.hideBody = false,
    this.hideSide = false,
    this.enableFullScreenIcon = true,
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
    this.sideEmptyWidget,
    this.initSelectedModel,
    this.initSelectedIndex = -1,
    this.defaultBodyWidth = 0.3,
    this.hideBody = false,
    this.hideSide = false,
    this.minBodyFactor,
    this.minBodyWidth = 400,
    this.maxBodyWidth,
    this.minSideFactor = 0.3,
    this.minSideWidth = 0,
    this.maxSideWidth ,
    this.slideWidth = 15,
    this.topPosition = 10,
    this.enableFullScreenIcon = true,
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

