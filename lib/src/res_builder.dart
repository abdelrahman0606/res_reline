import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';

/// A convenience builder widget that provides a [ResHelper] scoped to the
/// current layout constraints.
///
/// Useful for one-off responsive sections without reaching for the global
/// singleton.
class ResBuilder extends StatelessWidget {
  const ResBuilder({
    super.key,
    this.res,
    required this.builder,
    this.mobileBreakpoint = 600,
    this.desktopBreakpoint = 1024,
  });

  /// Optional pre-built [ResHelper]. When omitted, a scoped helper is created
  /// using [mobileBreakpoint] and [desktopBreakpoint].
  final ResHelper? res;

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    ResHelper res,
  ) builder;

  final double mobileBreakpoint;
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    final rs = res ??
        ResHelper.scoped(
          screenSize: ResHelper.instance.screenSize,
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
