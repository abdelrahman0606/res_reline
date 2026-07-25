part of 'main_helper.dart';

mixin MyResFont on _BaseResHelper {
  // ─── These come from ResInit.designSize — not hardcoded fields ────────────

  /// The width of your design mockup (set via [ResInit.designSize]).
  double get baseWidth => _designSize.width;

  /// The height of your design mockup (set via [ResInit.designSize]).
  double get baseHeight => _designSize.height;

  /// Conservative height base used for layout sizing (slightly smaller than
  /// [baseHeight] to leave room for system bars). Set via [ResInit].
  double get baseHeightForSetHeight => _designHeightForLayout;

  // ─── Scaling ─────────────────────────────────────────────────────────────

  /// Scale by design width — use for horizontal sizes.
  double setWidth(double w, {double? scaleFraction}) {
    final sf = scaleFraction ?? _scaleFraction;
    return w * sf * (width / baseWidth);
  }

  /// Scale by design layout height — use for vertical sizes.
  double setHeight(double h, {double? scaleFraction}) {
    final sf = scaleFraction ?? _scaleFraction;
    return h * sf * (height / baseHeightForSetHeight);
  }

  /// Scale by raw design height — good for font sizes & proportional values.
  double h(double value) => value * height / baseHeight;

  /// Scale by raw design width — bare width ratio.
  double w(double value) => value * width / baseWidth;

  /// Radius — scales by the minimum of width and height ratios.
  ///
  /// Ideal for border radii so they stay proportional on both axes.
  double r(double value) => value * min(width / baseWidth, height / baseHeight);

  /// Aspect-ratio-aware scale.
  double aspect(double value) =>
      value * ((width / height) / (baseWidth / baseHeight));

  /// Scale a font size — uses `min(scaleWidth, height/300)` to prevent
  /// excessive growth on very tall screens.

  double setSp(
      double fontSize, {
        double? scaleFraction,
        double? minSize,
        double? maxSize,
      }) {
    scaleFraction ??= _scaleFraction;

    final widthScale = width / baseWidth;
    final heightScale = height / baseHeight;

    final scale = min(widthScale, heightScale);

    final result =
        fontSize * (1 + (scale - 1) * scaleFraction);

    return result.clamp(
      minSize ?? fontSize * 0.9,
      maxSize ?? fontSize * 1.5,
    );
  }

  /// Range-clamped font size — adds an upper cap via [maxFontSize].
  double setSpWithRange(
    double fontSize, {
    double maxFontSize = 24,
    double? scaleFraction,
  }) {
    final sf = scaleFraction ?? _scaleFraction;
    final scaleText = min(
      width / 500,
      min(height / 300, (50 * maxFontSize) / height),
    );
    return fontSize * scaleText * sf;
  }
}
