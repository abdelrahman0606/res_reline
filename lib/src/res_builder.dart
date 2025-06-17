import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';

class ResBuilder extends StatelessWidget {
  const ResBuilder({super.key, this.res, required this.builder});
  final ResHelper? res;
  final Widget Function(BuildContext context,BoxConstraints constraints , ResHelper res ) builder;

  @override
  Widget build(BuildContext context) {
    final rs =res ?? ResHelper(context: context);
    return LayoutBuilder(
      builder: (context, constraints) {
        rs.resizer = Size(constraints.maxWidth, constraints.maxHeight);
        return builder(context,  constraints,rs);
      },
    );
  }
}
