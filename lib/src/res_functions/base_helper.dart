part of 'main_helper.dart';

abstract class _BaseResHelper {
  _BaseResHelper._({
    Size? mobSSize,
    Size? mobMSize,
    Size? mobLSize,
    Size? tabSSize,
    Size? tabMSize,
    Size? tabLSize,
    Size? deskSSize,
    Size? deskMSize,
    Size? deskLSize,
    BoxConstraints? constraints,
    this.size,
  })  : mobSSize = mobSSize ?? const Size(320, 568),
        mobMSize = mobMSize ?? const Size(375, 667),
        mobLSize = mobLSize ?? const Size(500, 896),
        tabSSize = tabSSize ?? const Size(768, 1024),
        tabMSize = tabMSize ?? const Size(820, 1024),
        tabLSize = tabLSize ?? const Size(900, 1280),
        deskSSize = deskSSize ?? const Size(1024, 768),
        deskMSize = deskMSize ?? const Size(1366, 768),
        deskLSize = deskLSize ?? const Size(1920, 1080),
        constraintsMutable = constraints;

  // ─── Screen size ────────────────────────────────────────────────────────

  /// The current device screen size. Updated by [ResHelper.configure].
  Size? size;

  /// Allows LayoutBuilder callbacks to override the size for this instance.
  set resizer(Size value) => size = value;

  Size get screenSize => size ?? const Size(375, 812);

  double get width => screenSize.width;
  double get height => screenSize.height;

  // ─── Design reference (from ResInit.designSize) ─────────────────────────

  /// The mockup size passed to [ResInit]. Drives all scale calculations.
  Size _designSize = const Size(375, 812);

  /// The height base used by [setHeight] for layout (slightly conservative).
  double _designHeightForLayout = 700.0;

  /// Global scale multiplier — set via [ResInit.scaleFraction].
  double _scaleFraction = 1.0;

  // ─── Breakpoint sizes (mutable so configure() can override) ────────────

  Size mobSSize;
  Size mobMSize;
  Size mobLSize;
  Size tabSSize;
  Size tabMSize;
  Size tabLSize;
  Size deskSSize;
  Size deskMSize;
  Size deskLSize;

  BoxConstraints? constraintsMutable;

  /// Alias kept for API compatibility.
  BoxConstraints? get constraints => constraintsMutable;

  // ─── Platform detection ──────────────────────────────────────────────────

  bool get isMobile => width <= mobLSize.width;
  bool get isTablet => width > mobLSize.width && width <= tabLSize.width;
  bool get isDesktop => width > tabLSize.width;

  bool get isMobileS => width <= mobSSize.width;
  bool get isMobileM => width > mobSSize.width && width <= mobMSize.width;
  bool get isMobileL => width > mobMSize.width && width <= mobLSize.width;
  bool get isTabletS => width > mobLSize.width && width <= tabSSize.width;
  bool get isTabletM => width > tabSSize.width && width <= tabMSize.width;
  bool get isTabletL => width > tabMSize.width && width <= tabLSize.width;
  bool get isDesktopS => width > tabLSize.width && width <= deskSSize.width;
  bool get isDesktopM => width > deskSSize.width && width <= deskMSize.width;
  bool get isDesktopL =>
      width > deskMSize.width &&
      (constraintsMutable == null || width <= constraintsMutable!.maxWidth);

  Size get platSize {
    return switch (plat) {
      ScreenType.mobileS => mobSSize,
      ScreenType.mobileM => mobMSize,
      ScreenType.mobileL => mobLSize,
      ScreenType.tabletS => tabSSize,
      ScreenType.tabletM => tabMSize,
      ScreenType.tabletL => tabLSize,
      ScreenType.desktopS => deskSSize,
      ScreenType.desktopM => deskMSize,
      ScreenType.desktopL => deskLSize,
      ScreenType.outOfRange => deskLSize,
    };
  }

  ScreenType get plat {
    if (isMobileS) return ScreenType.mobileS;
    if (isMobileM) return ScreenType.mobileM;
    if (isMobileL) return ScreenType.mobileL;
    if (isTabletS) return ScreenType.tabletS;
    if (isTabletM) return ScreenType.tabletM;
    if (isTabletL) return ScreenType.tabletL;
    if (isDesktopS) return ScreenType.desktopS;
    if (isDesktopM) return ScreenType.desktopM;
    if (isDesktopL) return ScreenType.desktopL;
    return ScreenType.outOfRange;
  }

  // ─── Debug helpers ───────────────────────────────────────────────────────

  Future<void>? _debounce;

  void aiPrinter() {
    _debounce?.ignore();
    _debounce = Future.delayed(const Duration(seconds: 1), () {
      printDebug();
      printPlatsSizes();
    });
  }

  void printDebug() {
    debugPrint(
      '====================================\n'
      '${plat.toMap} =====> $width',
    );
  }

  void printPlatsSizes() {
    debugPrint(
      '====================================\n'
      'mobSSize: $mobSSize,\n'
      'mobMSize: $mobMSize,\n'
      'mobLSize: $mobLSize,\n'
      'tabSSize: $tabSSize,\n'
      'tabMSize: $tabMSize,\n'
      'tabLSize: $tabLSize,\n'
      'deskSSize: $deskSSize,\n'
      'deskMSize: $deskMSize,\n'
      'deskLSize: $deskLSize,',
    );
  }
}
