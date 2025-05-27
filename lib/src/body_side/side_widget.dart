import 'package:flutter/material.dart';

class SideWidget extends StatefulWidget {
  const SideWidget({
    super.key,
    required this.width,
    this.sideWidget,
    this.changeFullScreen,
    this.close,
    this.enableClose = true,
    this.enableFullScreen = true,
    this.topPosition = 0,
    this.endPosition = 10.0,
    this.isFullScreen = false,
  });

  final Widget? sideWidget;
  final void Function(bool value)? changeFullScreen;
  final void Function()? close;
  final double width;
  final bool enableClose;
  final bool isFullScreen;
  final bool enableFullScreen;
  final double topPosition;
  final double endPosition;

  @override
  State<SideWidget> createState() => _SideWidgetState();
}

class _SideWidgetState extends State<SideWidget> {
  bool isHovered = true; // State to track hover
  bool isFullScreen = false;
  @override
  void initState() {
    isFullScreen =widget.isFullScreen;
    print("initState: $isFullScreen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextDirection direction = Directionality.of(context);
    return SizedBox(
      width: widget.width,
      child: Stack(
          children: [
            Center(
              child:
              widget.sideWidget ??
                  const Text(
                    'Select an item from the list',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
            ),
            if (isHovered &&( widget.enableFullScreen || widget.enableClose))
              Positioned.directional(
                top: widget.topPosition,
                end: widget.endPosition,
                textDirection: direction,
                child: Column(
                  children: [
                    if (widget.enableClose) _closeButton(),
                    const SizedBox(height: 5),
                    if (widget.enableFullScreen) _zoomButton(),
                  ],
                ),
              ),
          ],
        ),
    );
  }

  void _changeHover(bool value) {
    if (widget.enableClose || widget.enableFullScreen)
      {
      if (value != isHovered) {
        setState(() {
          isHovered = value;
        });
      }
  }
  }

  Widget _zoomButton() => FloatingActionButton.small(
    onPressed: () {
      isFullScreen = !isFullScreen;
      widget.changeFullScreen?.call(isFullScreen);
    },
    child: Tooltip(
      exitDuration: const Duration(milliseconds: 20),
      message: isFullScreen ? 'Exit Fullscreen' : 'Enter Fullscreen',
      child: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
    ),
  );

  Widget _closeButton() => FloatingActionButton.small(
    backgroundColor: Colors.white,
    onPressed: widget.close,
    child: const Tooltip(
      exitDuration: Duration(milliseconds: 20),
      message: 'Close Right Panel',
      child: Icon(Icons.close, color: Colors.red),
    ),
  );
}
