part of 'masonry_layout.dart';

/// A single entry in a [MasonryLayout] or [SliverMasonryLayout].
/// Declares *what* to show and *which zone* it belongs to. Either [child]
/// or [builder] must be provided; when both are given [builder] wins.
@immutable
class MasonryItem {
  const MasonryItem({
    Widget? child,
    this.width = MasonryWidth.body,
    this.builder,
  })  : assert(
          child != null || builder != null,
          'MasonryItem: provide at least one of child or builder.',
        ),
        _child = child;

  final Widget? _child;

  /// Which layout zone this item should occupy. Defaults to [MasonryWidth.body].
  final MasonryWidth width;

  /// Optional context-aware builder called before the child list is handed to
  /// the render-object layer.
  ///
  /// Parameters:
  /// * `toggle` — `true` when the layout is in **toggle mode** and this
  ///   item's zone is the currently active one (displayed solo at full width).
  ///   `false` in two-column mode, collapsed mode, or when this item's zone
  ///   is hidden.
  /// * `maxWidth` — the pixel width the layout will allocate to this item
  ///   in the current configuration.
  ///
  /// When non-`null`, [builder] takes precedence over the `child` argument.
  final Widget Function(bool toggle, double maxWidth)? builder;

  /// Resolves the widget to render, called internally by [MasonryLayout] and
  /// [SliverMasonryLayout].
  Widget resolve(bool toggle, double maxWidth) {
    return builder?.call(toggle, maxWidth) ?? _child!;
  }
}
