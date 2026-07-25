import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';

/// Sliver equivalent of [ResPageSizer].
///
/// Provides a [ResHelper] scoped to sliver constraints via [SliverLayoutBuilder].
class ResSliverPageSizer extends StatefulWidget {
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

  final Widget Function(
    BuildContext context,
    SliverConstraints constraints,
    ResHelper rs,
  ) builder;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildHelper();
  }

  void _buildHelper() {
    final ref = ResHelper.instance;
    rs = ResHelper.scoped(
      screenSize: ref.screenSize,
      mobSSize: widget.mobSSize?.call(ref.mobSSize),
      mobMSize: widget.mobMSize?.call(ref.mobMSize),
      mobLSize: widget.mobLSize?.call(ref.mobLSize),
      tabSSize: widget.tabSSize?.call(ref.tabSSize),
      tabMSize: widget.tabMSize?.call(ref.tabMSize),
      tabLSize: widget.tabLSize?.call(ref.tabLSize),
      deskSSize: widget.deskSSize?.call(ref.deskSSize),
      deskMSize: widget.deskMSize?.call(ref.deskMSize),
      deskLSize: widget.deskLSize?.call(ref.deskLSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        rs.resizer = Size(
          constraints.crossAxisExtent,
          constraints.viewportMainAxisExtent,
        );
        return widget.builder(context, constraints, rs);
      },
    );
  }
}
