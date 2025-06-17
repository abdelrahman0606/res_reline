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
    required this.size,
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
  late Size size;

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

  double get width => size.width;

  double get height => size.height;



  Size get getPlatSize {
    return switch (getPlat) {
      ResPlateType.isMobileS => mobSSize,
      ResPlateType.isMobileM => mobMSize,
      ResPlateType.isMobileL => mobLSize,
      ResPlateType.isTabletS => tabSSize,
      ResPlateType.isTabletM => tabMSize,
      ResPlateType.isTabletL => tabLSize,
      ResPlateType.isDesktopS => deskSSize,
      ResPlateType.isDesktopM => deskMSize,
      ResPlateType.isDesktopL => deskLSize,
      ResPlateType.outOfRange => deskLSize,
    };
  }

  ResPlateType get getPlat {
    if (isMobileS) return ResPlateType.isMobileS;
    if (isMobileM) return ResPlateType.isMobileM;
    if (isMobileL) return ResPlateType.isMobileL;
    if (isTabletS) return ResPlateType.isTabletS;
    if (isTabletM) return ResPlateType.isTabletM;
    if (isTabletL) return ResPlateType.isTabletL;
    if (isDesktopS) return ResPlateType.isDesktopS;
    if (isDesktopM) return ResPlateType.isDesktopM;
    if (isDesktopL) {
      return ResPlateType.isDesktopL;
    } else {
      return ResPlateType.outOfRange;
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
