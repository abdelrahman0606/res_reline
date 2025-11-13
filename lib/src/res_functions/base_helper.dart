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
    this.constrains,
    this.size,
    this.context,
  }):
  mobSSize = mobSSize ??= const Size(320, 568),
       mobMSize = mobMSize ??= const Size(375, 667),
       mobLSize = mobLSize ??= const Size(500, 896),
       tabSSize = tabSSize ??= const Size(768, 1024),
       tabMSize = tabMSize ??= const Size(820, 1024),
       tabLSize = tabLSize ??= const Size(900, 1280),
       deskSSize = deskSSize ??= const Size(1024, 768),
       deskMSize = deskMSize ??= const Size(1366, 768),
       deskLSize = deskLSize ??= const Size(1920, 1080) ;

  late Size? size;
  late BuildContext? context;
  Size get screenSize =>size ?? MediaQuery.sizeOf(context!);
  double get width => screenSize.width;
  double get height => screenSize.height;
  set resizer(Size size) =>this.size=size;

  /// plats width
  final Size mobSSize;
  final Size mobMSize;
  final Size mobLSize;
  final Size tabSSize;
  final Size tabMSize;
  final Size tabLSize;
  final Size deskSSize;
  final Size deskMSize;
  final Size deskLSize;
  final BoxConstraints? constrains;

  /// what is plats
  bool get isMobile => width <= mobLSize.width;

  bool get isTablet => width > mobLSize.width && width <= tabLSize.width;

  bool get isDesktop => width > tabLSize.width;

  /// what is plats details
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
      (constrains != null && width <= constrains!.maxWidth ||
          constrains == null);

  /// get


  Size get getPlatSize {
    return switch (getPlat) {
      ScreenType.isMobileS => mobSSize,
      ScreenType.isMobileM => mobMSize,
      ScreenType.isMobileL => mobLSize,
      ScreenType.isTabletS => tabSSize,
      ScreenType.isTabletM => tabMSize,
      ScreenType.isTabletL => tabLSize,
      ScreenType.isDesktopS => deskSSize,
      ScreenType.isDesktopM => deskMSize,
      ScreenType.isDesktopL => deskLSize,
      ScreenType.outOfRange => deskLSize,
    };
  }

  ScreenType get getPlat {
    if (isMobileS) return ScreenType.isMobileS;
    if (isMobileM) return ScreenType.isMobileM;
    if (isMobileL) return ScreenType.isMobileL;
    if (isTabletS) return ScreenType.isTabletS;
    if (isTabletM) return ScreenType.isTabletM;
    if (isTabletL) return ScreenType.isTabletL;
    if (isDesktopS) return ScreenType.isDesktopS;
    if (isDesktopM) return ScreenType.isDesktopM;
    if (isDesktopL) {
      return ScreenType.isDesktopL;
    } else {
      return ScreenType.outOfRange;
    }

  }

  Future<void>? _debounce;

  void get aiPrinter {
    _debounce?.ignore();

    _debounce = Future.delayed(const Duration(seconds: 1), () {
      printDebug;
      printPlatsSizes;
    });
  }

  void get printDebug {
    debugPrint(
      "====================================\n"
      "${getPlat.toMap}=====> $width",
    );
  }

  void get printPlatsSizes {
    debugPrint(
      "====================================\n"
      "mobSSize: $mobSSize,\n"
      "mobMSize: $mobMSize,\n"
      "mobLSize: $mobLSize,\n"
      "tabSSize: $tabSSize,\n"
      "tabMSize: $tabMSize,\n"
      "tabLSize: $tabLSize,\n"
      "deskSSize: $deskSSize,\n"
      "deskMSize: $deskMSize,\n"
      "deskLSize: $deskLSize,",
    );
  }
}
