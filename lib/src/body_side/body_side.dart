import 'package:flutter/material.dart';
import 'package:res_reline/src/body_side/separate_widget.dart';
import 'package:res_reline/src/body_side/side_widget.dart';

class ResBodySide<T> extends StatefulWidget {
  final double defaultBodyWidth; // New property
  final Widget? body;
  final Widget? side;
  final int? itemCount;
  final ScrollPhysics? physics;
  final Widget Function(
      BuildContext, int index, Function(int index, {T? model,bool refresh}) onSelector)? itemBuilder;
  final Function(BuildContext context,int index, T? model)? sideBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool isSelector;
  final double minBodyWidth;
  final double minSideWidth;
  final Function(bool isMobile, int index)? onSelect;
  final bool hideBody;
  final bool hideSide;
  final Widget slideWidget;

  const ResBodySide({
    super.key,
    required this.body,
    required this.side,
    this.defaultBodyWidth = 0.7, // Default value
    this.minBodyWidth = 0.3,
    this.minSideWidth = 0.3,
    this.hideBody = false,
    this.hideSide = false,
    this.slideWidget = const SeparateWidget(),
  })  : itemBuilder = null,
        separatorBuilder = null,
        isSelector = false,
        sideBuilder = null,
        physics = null,
        itemCount = null,
        onSelect = null;

  const ResBodySide.selector({
    super.key,
    required this.itemBuilder,
    this.sideBuilder,
    this.defaultBodyWidth = 0.3,
    this.hideBody = false,
    this.hideSide = false,
    this.minBodyWidth = 0.3,
    this.minSideWidth = 0.3,
    this.slideWidget = const SeparateWidget(),
  })  : body = null,
        side = null,
        physics = null,
        onSelect = null,
        itemCount = null,
        separatorBuilder = null,
        isSelector = true;

  @override
  State<ResBodySide> createState() => _ResBodySideState<T>();
}

class _ResBodySideState<T> extends State<ResBodySide<T>> {
  double bodyWidth = 0.5;
  bool isFullScreen = false;
  int selectedIndex = -1;
  T? selectedModel;

  @override
  void initState() {
    bodyWidth = widget.defaultBodyWidth;
    super.initState();
  }

  void _onSelector(int index, {T? model, bool refresh = false}) {
    if (selectedIndex == index&& !refresh) return;
    if(mounted) {
      setState(() {
        selectedIndex = index;
        selectedModel = model;
        if (_isSideHided && widget.sideBuilder != null) {
          bodyWidth = 1 - widget.minSideWidth;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (widget.isSelector) {
      return _buildBody(
          context: context,
          bodyWidget: widget.itemBuilder!(context, selectedIndex, _onSelector),
          sideWidget: selectedIndex >= 0
              ? widget.sideBuilder?.call(context, selectedIndex,selectedModel)
              : null);
    }

    return _buildBody(
        context: context, bodyWidget: widget.body!, sideWidget: widget.side!);
  }

  bool _increased(oldValue) => bodyWidth > oldValue;

  bool get _isBodyHided => widget.hideBody && bodyWidth < widget.minBodyWidth;

  bool get _isSideHided => widget.hideSide && _sideWidth < widget.minSideWidth;

  double get _sideWidth => 1 - bodyWidth;

  Widget _buildBody({
    required BuildContext context,
    required Widget bodyWidget,
    required Widget? sideWidget,
  }) =>
      LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            if (!isFullScreen && (!_isBodyHided))
              SizedBox(
                  width: (_isSideHided
                      ? constraints.maxWidth - 20
                      : constraints.maxWidth * bodyWidth),
                  child: bodyWidget),
            if (!isFullScreen && sideWidget != null) _sideBar(constraints),
            if (!_isSideHided && sideWidget != null )
              Expanded(
                child: SideWidget(
                  width: constraints.maxWidth * (1 - bodyWidth),
                  sideWidget: sideWidget,
                  enableClose: widget.hideSide,
                  enableFullScreen: true,
                  isFullScreen: isFullScreen,
                  changeFullScreen: (v) {
                    setState(() {
                      isFullScreen = v;
                    });
                  },
                  close: () {
                    setState(() {
                      selectedIndex = -1;
                      bodyWidth =1;
                      isFullScreen = false;
                    });
                  },
                ),
              ),
          ],
        ),
      );

  Widget _sideBar(constraints) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onHorizontalDragUpdate: (DragUpdateDetails details) {
      setState(() {
        final oldWidth = bodyWidth;
        TextDirection textDirection = Directionality.of(context);
        if (textDirection == TextDirection.ltr) {
          bodyWidth += details.primaryDelta! / constraints.maxWidth;
        } else {
          bodyWidth -= details.primaryDelta! / constraints.maxWidth;
        }
        // leftWidth = leftWidth.clamp(0.2, 1 - widget.minLeftWidth); // Limit resizing range
        double bodyClamp = widget.hideBody ? 0 : widget.minBodyWidth;
        double sideClamp = widget.hideSide ? 1 : 1.0 - widget.minSideWidth;
        bodyWidth = bodyWidth.clamp(bodyClamp, sideClamp);
        if (_increased(oldWidth) && _isBodyHided) {
          bodyWidth = widget.minBodyWidth;
        } else if (!_increased(oldWidth) && _isSideHided) {
          bodyWidth = 1 - widget.minSideWidth;
        }
      });
    },
    child: widget.slideWidget,
  );
}

