import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';
import 'main_responsive.dart';

class ResBuilder extends StatelessWidget {
  const ResBuilder({super.key, this.res, required this.builder});
  final ResHelper? res;
  final Widget Function(BuildContext context,BoxConstraints constraints , ResHelper rs ) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rs =res?? MyRes.of(context);
        return builder(context,  constraints,rs);
      },
    );
  }
}
