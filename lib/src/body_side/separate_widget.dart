import 'package:flutter/material.dart';


class SeparateWidget extends StatefulWidget {
  const SeparateWidget({super.key});

  @override
  _SeparateWidgetState createState() => _SeparateWidgetState();
}

class _SeparateWidgetState extends State<SeparateWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only( right: 5, left: 5),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedContainer(
          decoration: BoxDecoration(
              color: _isHovered
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(20)),
          duration: const Duration(milliseconds: 200),
          width: _isHovered ? 8.0 : 5.0,
        ),
      ),
    );
  }

  void _onHover(bool isHovered) {
    if(_isHovered == isHovered) return;
    setState(() {
      _isHovered = isHovered;
    });
  }
}
