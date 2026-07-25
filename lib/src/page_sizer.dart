import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';

/// A widget that provides a [ResHelper] scoped to the current layout
/// constraints, with optional per-breakpoint size overrides.
///
/// The builder receives a scoped [ResHelper] whose screen size is updated
/// on every layout pass from [LayoutBuilder] constraints.
class ResPageSizer extends StatefulWidget {
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

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    ResHelper rs,
  ) builder;

  /// Optional global breakpoint rescaler applied to all sizes.
  final Size? Function(Size max)? reSizePlat;

  /// Per-breakpoint size overrides (takes priority over [reSizePlat]).
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildHelper();
  }

  void _buildHelper() {
    final ref = ResHelper.instance; // read breakpoint sizes from singleton
    rs = ResHelper.scoped(
      screenSize: ref.screenSize,
      mobSSize: (widget.mobSSize ?? widget.reSizePlat)?.call(ref.mobSSize),
      mobMSize: (widget.mobMSize ?? widget.reSizePlat)?.call(ref.mobMSize),
      mobLSize: (widget.mobLSize ?? widget.reSizePlat)?.call(ref.mobLSize),
      tabSSize: (widget.tabSSize ?? widget.reSizePlat)?.call(ref.tabSSize),
      tabMSize: (widget.tabMSize ?? widget.reSizePlat)?.call(ref.tabMSize),
      tabLSize: (widget.tabLSize ?? widget.reSizePlat)?.call(ref.tabLSize),
      deskSSize: (widget.deskSSize ?? widget.reSizePlat)?.call(ref.deskSSize),
      deskMSize: (widget.deskMSize ?? widget.reSizePlat)?.call(ref.deskMSize),
      deskLSize: (widget.deskLSize ?? widget.reSizePlat)?.call(ref.deskLSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: LayoutBuilder(
        builder: (context, constraints) {
          rs.resizer = Size(constraints.maxWidth, constraints.maxHeight);
          return widget.builder(context, constraints, rs);
        },
      ),
    );
  }
}
