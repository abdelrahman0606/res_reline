import 'package:flutter/material.dart';

class ResWrap extends StatefulWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final WrapAlignment runAlignment;
  final MainAxisSize mainAxisSize;

  const ResWrap({
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.runAlignment=WrapAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    required this.children,
    super.key,
  });

  @override
  _ResWrapState createState() => _ResWrapState();
}

class _ResWrapState extends State<ResWrap> {
  final List<GlobalKey> _keys = [];
  bool _isHorizontal = false;
  @override
  void initState() {
    super.initState();
    _keys.addAll(List.generate(widget.children.length, (_) => GlobalKey()));
  }

  double _getTotalChildrenWidth() {
    double totalWidth = 0;
    for (var key in _keys) {
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          totalWidth += box.size.width + widget.spacing;
        }
      }
    }
    return totalWidth;
  }



  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double totalChildrenWidth = _getTotalChildrenWidth();
        bool isHorizontal = totalChildrenWidth < availableWidth;
        if(_isHorizontal!=isHorizontal){
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {
              _isHorizontal=isHorizontal;
            });
          });

        }
        return AnimatedSize(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 300),
            child: isHorizontal
                ? Row(
              crossAxisAlignment: widget.crossAxisAlignment,
              mainAxisAlignment:widget.mainAxisAlignment,
              mainAxisSize: widget.mainAxisSize,
              children: List.generate(widget.children.length, (index) {
                return Padding(
                  key: _keys[index],
                  padding: EdgeInsets.only(right: widget.spacing),
                  child: widget.children[index],
                );
              }),
            )
                : Column(
              crossAxisAlignment: widget.crossAxisAlignment,
              mainAxisAlignment: widget.mainAxisAlignment,
              spacing: widget.spacing,
              children: List.generate(widget.children.length, (index) {
                return Container(
                  key: _keys[index],
                  child: widget.children[index],
                );
              }),
            ));
      },
    );
  }
}

// import 'package:flutter/material.dart';
//
// class ResWrap extends StatefulWidget {
//   const ResWrap({super.key, required this.children});
//
//   final List<Widget> children;
//
//   @override
//   State<ResWrap> createState() => _ResWrapState();
// }
//
// class _ResWrapState extends State<ResWrap> {
//   late Widget _widget = Row(
//     children: widget.children,
//   );
//
//   @override
//   void initState() {
//     FlutterError.onError = (FlutterErrorDetails details) {
//       if (details.exception.toString().contains("A RenderFlex overflowed")) {
//         print("⚠️ RenderFlex Overflow detected!");
//         // You can log, report, or modify UI here
//         _widget = Column(
//           children: widget.children,
//         );
//       } else {
//         FlutterError.presentError(details);
//       }
//     };
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _widget;
//   }
// }
