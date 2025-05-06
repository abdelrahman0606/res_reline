part of 'body_side_fixed.dart';

class _ResBodySideFixedState<T> extends State<ResBodySideFixed<T>> {
  @override
  void initState() {
    selectedIndex = widget.initSelectedIndex;
    if(selectedIndex>=0) selectedModel = widget.initSelectedModel?.call(selectedIndex);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ResBodySideFixed<T> oldWidget) {
    if (widget.initSelectedIndex != oldWidget.initSelectedIndex ||
        widget.initSelectedModel != oldWidget.initSelectedModel) {
      selectedIndex = widget.initSelectedIndex;
      if(selectedIndex>=0) selectedModel = widget.initSelectedModel?.call(selectedIndex);
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  final ValueNotifier<bool> isFullScreen = ValueNotifier(false);
  int selectedIndex = -1;
  T? selectedModel;
  double? _sideWidth;

  bool get isSelected => selectedIndex >= 0 || selectedModel != null;

  void _onSelector(int index, {T? model, bool refresh = false}) {
    if (selectedIndex == index && !refresh) return;
    if (mounted) {
      setState(() {
        selectedIndex = index;
        selectedModel = model;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSelector) {
      return _buildLayout(
        context: context,
        bodyWidget: widget.bodyBuilder!(
          context,
          selectedIndex,
          _onSelector,
        ),
        sideWidget: isSelected
            ? widget.sideBuilder?.call(context, selectedIndex, selectedModel)
            : null,
      );
    }

    return _buildLayout(
      context: context,
      bodyWidget: widget.body!,
      sideWidget: widget.side!,
    );
  }

  Widget _buildLayout({
    required BuildContext context,
    required Widget bodyWidget,
    required Widget? sideWidget,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth =constraints.maxWidth;
        final minSide =
            widget.minSideWidth < screenWidth ? widget.minSideWidth : 0.0;
        final maxSide = widget.maxSideWidth > screenWidth
            ? screenWidth
            : widget.maxSideWidth;

        final slideWidth = isSelected ? 30.0 : 0; // 👈 عرض السلايدر الثابت

        // ⏳ احسب العرض الأولي للـ side فقط مرة واحدة
        _sideWidth ??= (constraints.maxWidth * widget.minSideWidth)
            .clamp(minSide, maxSide);

        final sideWidth = isSelected ? _sideWidth!.clamp(0.0, constraints.maxWidth) : 0.0;
        final bodyWidth = (constraints.maxWidth - sideWidth - slideWidth)
            .clamp(0.0, screenWidth);
        print("sideWidth: $sideWidth, bodyWidth: $bodyWidth");

        return AnimatedSize(
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(milliseconds: 200),
          child: Stack(
            children: [
              // 🟦 Body ثابت
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: bodyWidth > widget.minBodyWidth
                      ? bodyWidth
                      : widget.minBodyWidth,
                  child: bodyWidget,
                ),
              ),
              Positioned.fill(
                child: ValueListenableBuilder<bool>(
                  valueListenable: isFullScreen,
                  builder: (context, value, child) => AnimatedSize(
                    duration: Duration(milliseconds: 200),
                    child: Row(
                      children: [
                        if (!value)
                          SizedBox(
                            width: bodyWidth,
                          ),
                        if (!value &&
                            sideWidget != null &&
                            isSelected &&
                            bodyWidth > 0)
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onHorizontalDragUpdate: (details) {
                              setState(() {
                                _sideWidth = (_sideWidth! - details.delta.dx)
                                    .clamp(minSide, maxSide);
                              });
                            },
                            child: widget.slideWidget,
                          ),
                        if (sideWidget != null && isSelected)
                          AnimatedContainer(
                            duration: Duration(milliseconds: 0),
                            width:
                                value ? constraints.maxWidth - 50 : sideWidth,
                            child: SideWidget(
                              width: value ? constraints.maxWidth - 50 : sideWidth,
                              isFullScreen: value,
                              topPosition: widget.topPosition,
                              sideWidget: sideWidget,
                              enableClose: widget.hideSide,
                              enableFullScreen: bodyWidth > 0,
                              changeFullScreen: (v) {
                                isFullScreen.value = v;
                              },
                              close: () {
                                widget.onClose?.call();
                                setState(() {
                                  selectedIndex = -1;
                                  isFullScreen.value = false;
                                  selectedModel = null;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


