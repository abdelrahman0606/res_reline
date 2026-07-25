import 'package:flutter/widgets.dart';

/// An [InheritedWidget] that propagates the current screen [Size] down the
/// widget tree and triggers rebuilds on dependent widgets when it changes.
///
/// Inserted by [ResInit] — you do not need to use this directly.
class ResScope extends InheritedWidget {
  const ResScope({
    super.key,
    required this.screenSize,
    required super.child,
  });

  /// The current physical screen size stored in this scope.
  final Size screenSize;

  /// Retrieves the [ResScope] from the widget tree.
  ///
  /// Returns `null` if no [ResScope] is found (e.g. before [ResInit] is
  /// mounted).
  static ResScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ResScope>();

  @override
  bool updateShouldNotify(ResScope old) => screenSize != old.screenSize;
}
