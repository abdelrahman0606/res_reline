import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';
import 'package:res_reline/src/main_responsive.dart';


class ResSliverPageSizer extends StatefulWidget {
  final Widget Function(
      BuildContext context, SliverConstraints  constraints, ResHelper rs)
  builder;

  const ResSliverPageSizer({
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
  });

  /// plats width
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
  State<ResSliverPageSizer> createState() => _ResSliverPageSizerState();
}

class _ResSliverPageSizerState extends State<ResSliverPageSizer> {
  late ResHelper rs;

  @override
  void initState() {
    final of = MyRes.of(context);
    rs = MyRes.instance(
      context:  context,
      mobSSize: widget.mobSSize?.call(of.mobSSize),
      mobMSize: widget.mobMSize?.call(of.mobMSize),
      mobLSize: widget.mobLSize?.call(of.mobLSize),
      tabSSize: widget.tabSSize?.call(of.tabSSize),
      tabMSize: widget.tabMSize?.call(of.tabMSize),
      tabLSize: widget.tabLSize?.call(of.tabLSize),
      deskSSize: widget.deskSSize?.call(of.deskSSize),
      deskMSize: widget.deskMSize?.call(of.deskMSize),
      deskLSize: widget.deskLSize?.call(of.deskLSize),
    );
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        rs.resizer= Size(constraints.crossAxisExtent, constraints.viewportMainAxisExtent);
        return widget.builder(context, constraints, rs);
      },
    );
  }
}
