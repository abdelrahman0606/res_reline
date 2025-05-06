import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';

import 'main_responsive.dart';

class ResPageSizer extends StatefulWidget {
  final Widget Function(
          BuildContext context, BoxConstraints constraints, ResHelper rs)
      builder;

  const ResPageSizer({
    super.key,
    required this.builder,
    this.mobSSize,
    this.mobMSize,
    this.mobLSize,
    this.tabSSize,
    this.tabMSize,
    this.tabLSize,
    this.deskSSize,
    this.deskMSize,
    this.deskLSize,
    this.reSizePlat,
  });

  /// plats size =>control in plat size
  final Size? Function(Size max)? reSizePlat;
  final Size Function(Size max)? mobSSize;
  final Size Function(Size max)? mobMSize;
  final Size Function(Size max)? mobLSize;
  final Size Function(Size max)? tabSSize;
  final Size Function(Size max)? tabMSize;
  final Size Function(Size max)? tabLSize;
  final Size Function(Size max)? deskSSize;
  final Size Function(Size max)? deskMSize;
  final Size Function(Size max)? deskLSize;

  @override
  State<ResPageSizer> createState() => _ResPageSizerState();
}

class _ResPageSizerState extends State<ResPageSizer> {
  late ResHelper rs;

  @override
  void initState() {

    final of = MyRes.of(context);
    rs = MyRes.instance(
     context:  context,
      mobSSize:( widget.mobSSize??widget.reSizePlat)?.call(of.mobSSize),
      mobMSize: (widget.mobMSize??widget.reSizePlat)?.call(of.mobMSize),
      mobLSize: (widget.mobLSize??widget.reSizePlat)?.call(of.mobLSize),
      tabSSize: (widget.tabSSize??widget.reSizePlat)?.call(of.tabSSize),
      tabMSize: (widget.tabMSize??widget.reSizePlat)?.call(of.tabMSize),
      tabLSize: (widget.tabLSize??widget.reSizePlat)?.call(of.tabLSize),
      deskSSize: (widget.deskSSize??widget.reSizePlat)?.call(of.deskSSize),
      deskMSize: (widget.deskMSize??widget.reSizePlat)?.call(of.deskMSize),
      deskLSize: (widget.deskLSize??widget.reSizePlat)?.call(of.deskLSize),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: LayoutBuilder(
        builder: (context, constraints) {
          rs.resize = Size(constraints.maxWidth, constraints.maxHeight);
          return widget.builder(context, constraints, rs);
        },
      ),
    );
  }
}
