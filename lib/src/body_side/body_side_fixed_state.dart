part of 'body_side_fixed.dart';

class _ResBodySideFixedState<T> extends State<ResBodySideFixed<T>> {
  late double _minBodyWidth;

  late final ValueNotifier<int> _selectedIndexN;
  late final ValueNotifier<T?> _selectedModelN;
  final ValueNotifier<bool> _isFullScreenN = ValueNotifier(false);

  // The side width the USER asked for (via drag, or the initial default).
  // This is a *desire*, not necessarily what gets rendered — the actual
  // rendered side width is recomputed every layout pass in _buildStack
  // as screenWidth - bodyWidth(capped), so it reacts correctly to both
  // dragging AND screen-size changes.
  final ValueNotifier<double?> _sideWidthN = ValueNotifier(null);

  Widget? _cachedBody;

  @override
  void initState() {
    super.initState();
    _minBodyWidth = widget.minBodyWidth;
    _selectedIndexN = ValueNotifier(widget.initSelectedIndex);
    _selectedModelN = ValueNotifier(
      widget.initSelectedIndex >= 0
          ? widget.initSelectedModel?.call(widget.initSelectedIndex)
          : null,
    );
  }

  @override
  void didUpdateWidget(covariant ResBodySideFixed<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initSelectedIndex != oldWidget.initSelectedIndex &&
        widget.initSelectedIndex != _selectedIndexN.value) {
      _selectedIndexN.value = widget.initSelectedIndex;
      _selectedModelN.value =
          widget.initSelectedIndex >= 0
              ? widget.initSelectedModel?.call(widget.initSelectedIndex)
              : null;
    }

    if (widget.minBodyWidth != oldWidget.minBodyWidth) {
      setState(() => _minBodyWidth = widget.minBodyWidth);
    }

    if (widget.bodyBuilder != oldWidget.bodyBuilder ||
        widget.body != oldWidget.body) {
      _cachedBody = null;
    }
  }

  @override
  void dispose() {
    _selectedIndexN.dispose();
    _selectedModelN.dispose();
    _isFullScreenN.dispose();
    _sideWidthN.dispose();
    super.dispose();
  }

  bool get _isSelected =>
      _selectedIndexN.value >= 0 ||
      _selectedModelN.value != null ||
      (!widget.isSelector && !widget.hideSide);

  void _onSelector(int index, {T? model, bool refresh = false}) {
    if (_selectedIndexN.value == index && !refresh) return;
    if (!mounted) return;
    _selectedIndexN.value = index;
    _selectedModelN.value = model;
    setState(() {

    });
  }

  void _closeSide() {
    widget.onClose?.call();
    if (!mounted) return;
    _selectedIndexN.value = -1;
    _isFullScreenN.value = false;
    _selectedModelN.value = null;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget bodyWidget = RepaintBoundary(
      child:
          _cachedBody ??=
              widget.isSelector
                  ? widget.bodyBuilder!(
                    context,
                    _selectedIndexN.value,
                    _onSelector,
                  )
                  : widget.body!,
    );

    return _buildLayout(
      context: context,
      bodyWidget: bodyWidget,
      sideWidgetBuilder:
          widget.isSelector
              ? (canBack) => widget.sideBuilder?.call(
                context,
                _selectedIndexN.value,
                _selectedModelN.value,
                _closeSide,
                canBack,
              )
              : (_) => widget.side!,
    );
  }

  Widget _buildLayout({
    required BuildContext context,
    required Widget bodyWidget,
    required Widget? Function(bool canBack) sideWidgetBuilder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

// Screen can't fit BOTH minimums at once.
        final notEnoughRoomForBoth =
            screenWidth < (widget.minSideWidth + _minBodyWidth);

// Only relevant when something is selected (a side panel would show
// at all) AND there isn't enough room for both minimums together.
// When nothing is selected, the separate `!_isSelected` branch in
// _buildStack already gives body the full screen — no change needed
// there.
        final forceSideFullScreen = _isSelected && notEnoughRoomForBoth;


        final rawMaxSide =
            min(widget.maxSideWidth ?? screenWidth, screenWidth) -
            _minBodyWidth;
        final minSide =
            widget.minSideWidth < screenWidth ? widget.minSideWidth : 0.0;
        final maxSide = rawMaxSide < minSide ? minSide : rawMaxSide;

        final rawMaxBody = widget.maxBodyWidth ?? screenWidth;
        final maxBody = (rawMaxBody < _minBodyWidth
                ? _minBodyWidth
                : rawMaxBody)
            .clamp(0.0, screenWidth);

        _sideWidthN.value ??= (screenWidth * widget.minSideWidth).clamp(
          minSide,
          maxSide,
        );

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          reverseDuration: const Duration(milliseconds: 200),
          child: ValueListenableBuilder<int>(
            valueListenable: _selectedIndexN,
            child: bodyWidget,
            builder: (context, selectedIndex, body) {
              return ValueListenableBuilder<T?>(
                valueListenable: _selectedModelN,
                child: body,
                builder: (context, selectedModel, body) {
                  return ValueListenableBuilder<double?>(
                    valueListenable: _sideWidthN,
                    child: body,
                    builder: (context, sideWidthRaw, body) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _isFullScreenN,
                        child: body,
                        builder: (context, isFullScreen, body) {
                          return _buildStack(
                            context: context,
                            constraints: constraints,
                            minSide: minSide,
                            maxSide: maxSide,
                            maxBody: maxBody,
                            body: body!,
                            sideWidgetBuilder: sideWidgetBuilder,
                            isFullScreen: isFullScreen,
                            desiredSide: sideWidthRaw ?? minSide,
                            forceSideFullScreen: forceSideFullScreen, // NEW
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStack({
    required BuildContext context,
    required BoxConstraints constraints,
    required double minSide,
    required double maxSide,
    required double maxBody,
    required Widget body,
    required Widget? Function(bool canBack) sideWidgetBuilder,
    required bool isFullScreen,
    required double desiredSide,
    required bool forceSideFullScreen,
  }) {
    final screenWidth = constraints.maxWidth;
    final slideWidth = (_isSelected && !forceSideFullScreen) ? widget.slideWidth : 0.0;

    double sideWidth;
    double bodyWidth;

    if (forceSideFullScreen) {
      sideWidth = screenWidth;
      bodyWidth = 0.0;
    } else if (!_isSelected) {
      // NEW: nothing is selected → no side panel at all → body owns
      // the entire screen width, unconditionally. maxBody only makes
      // sense as a constraint relative to a visible side, so it's
      // skipped here rather than eating space that has nowhere to go.
      sideWidth = 0.0;
      bodyWidth = screenWidth;
    } else {
      final available = screenWidth - slideWidth;

      sideWidth = desiredSide.clamp(minSide, maxSide);
      bodyWidth = (available - sideWidth).clamp(0.0, screenWidth);

      if (bodyWidth > maxBody) {
        final excess = bodyWidth - maxBody;
        bodyWidth = maxBody;
        sideWidth = (sideWidth + excess).clamp(minSide, maxSide);
      }
    }

    final canBack = bodyWidth <= 0;
    final actualSideWidget = sideWidgetBuilder(canBack);

    return Stack(
      children: [
        if (!forceSideFullScreen)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: bodyWidth > _minBodyWidth ? bodyWidth : _minBodyWidth,
              child: body,
            ),
          ),
        Positioned.fill(
          child: Row(
            children: [
              if (!isFullScreen && !forceSideFullScreen) SizedBox(width: bodyWidth),
              if (!isFullScreen &&
                  !forceSideFullScreen &&
                  actualSideWidget != null &&
                  _isSelected &&
                  bodyWidth > 0)
                MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      final next = (desiredSide - details.delta.dx).clamp(minSide, maxSide);
                      if (next != _sideWidthN.value) {
                        _sideWidthN.value = next;
                      }
                    },
                    child: widget.slideWidget,
                  ),
                ),
              if (actualSideWidget != null && _isSelected)
                SizedBox(
                  width: isFullScreen
                      ? constraints.maxWidth - 50
                      : (forceSideFullScreen ? screenWidth : sideWidth),
                  child: SideWidget(
                    width: isFullScreen
                        ? constraints.maxWidth - 50
                        : (forceSideFullScreen ? screenWidth : sideWidth),
                    isFullScreen: isFullScreen,
                    topPosition: widget.topPosition,
                    sideWidget: actualSideWidget,
                    enableClose: widget.hideSide,
                    enableFullScreen: widget.enableFullScreenIcon && bodyWidth > 0,
                    changeFullScreen: (v) => _isFullScreenN.value = v,
                    close: _closeSide,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
