import 'package:flutter/widgets.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';
import 'package:res_reline/src/res_scope.dart';

/// Initialises [ResHelper] and keeps it in sync with the device screen size.
///
/// Place this widget **above** [MaterialApp] (or any top-level app widget) so
/// that the singleton [ResHelper.instance] is populated before any widget tree
/// builds.
///
/// ```dart
/// runApp(
///   ResInit(
///     designSize: const Size(375, 812), // matches your design mockups
///     child: MyApp(),                   // MaterialApp goes here
///   ),
/// );
/// ```
///
/// After this you can use every extension anywhere without a [BuildContext]:
/// ```dart
/// Container(
///   width: 100.w,
///   height: 50.setH,
///   child: Text('Hi', style: TextStyle(fontSize: 14.sp)),
/// )
/// ```
class ResInit extends StatefulWidget {
  const ResInit({
    super.key,
    required this.child,
    this.designSize = const Size(375, 812),
    this.scaleFraction,
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

  /// The widget below [ResInit] in the tree — typically your [MaterialApp].
  final Widget child;

  /// The screen size used in your design mockups, in logical pixels.
  ///
  /// This becomes [baseWidth] and [baseHeight] for all scale calculations.
  /// Defaults to `Size(375, 812)`.
  final Size designSize;

  /// Global scale multiplier applied to all [setWidth], [setHeight], and [setSp]
  /// calculations. Defaults to `1.0` (no extra scaling).
  final double? scaleFraction;

  /// Override breakpoint sizes if your project needs non-default values.
  final Size? mobSSize;
  final Size? mobMSize;
  final Size? mobLSize;
  final Size? tabSSize;
  final Size? tabMSize;
  final Size? tabLSize;
  final Size? deskSSize;
  final Size? deskMSize;
  final Size? deskLSize;

  @override
  State<ResInit> createState() => _ResInitState();
}

class _ResInitState extends State<ResInit> with WidgetsBindingObserver {
  Size? _size;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _update();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Called when the physical window size changes (rotation, resize, etc.)
    _update();
  }

  void _update() {
    final newSize = MediaQuery.sizeOf(context);
    if (newSize == _size) return; // nothing changed — skip rebuild

    setState(() => _size = newSize);

    // Update the singleton — stores only Size, never BuildContext.
    ResHelper.configure(
      newSize,
      designSize: widget.designSize,
      scaleFraction: widget.scaleFraction,
      mobSSize: widget.mobSSize,
      mobMSize: widget.mobMSize,
      mobLSize: widget.mobLSize,
      tabSSize: widget.tabSSize,
      tabMSize: widget.tabMSize,
      tabLSize: widget.tabLSize,
      deskSSize: widget.deskSSize,
      deskMSize: widget.deskMSize,
      deskLSize: widget.deskLSize,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = _size;

    // Before the first layout pass the size is not yet known — show nothing.
    if (size == null) return const SizedBox.shrink();

    return ResScope(
      screenSize: size,
      child: widget.child,
    );
  }
}
