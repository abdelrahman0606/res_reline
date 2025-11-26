import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';

class ResBuilder extends StatelessWidget {
  const ResBuilder({
    super.key,
    this.res,
    required this.builder,
     this.mobileBreakpoint=600,
     this.desktopBreakpoint=1024,
  });

  final ResHelper? res;
  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    ResHelper res,
  )
  builder;
  final double mobileBreakpoint;
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    final rs = res ?? ResHelper(context: context,
    mobSSize: Size(mobileBreakpoint, double.infinity),
    mobMSize: Size(mobileBreakpoint, double.infinity),
    mobLSize: Size(mobileBreakpoint, double.infinity),
    deskMSize: Size(desktopBreakpoint, double.infinity),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        rs.resizer = Size(constraints.maxWidth, constraints.maxHeight);
        return builder(context, constraints, rs);
      },
    );
  }
}
