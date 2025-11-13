enum ScreenType {
  isMobileS,
  isMobileM,
  isMobileL,
  isTabletS,
  isTabletM,
  isTabletL,
  isDesktopS,
  isDesktopM,
  isDesktopL,
  outOfRange,
}
extension PlatTypeEx on ScreenType {
  String get toMap => switch (this) {
    ScreenType.isMobileS => "MobileS",
    ScreenType.isMobileM => "MobileM",
    ScreenType.isMobileL => "MobileL",
    ScreenType.isTabletS => "TabletS",
    ScreenType.isTabletM => "TabletM",
    ScreenType.isTabletL => "TabletL",
    ScreenType.isDesktopS => "DesktopS",
    ScreenType.isDesktopM => "DesktopM",
    ScreenType.isDesktopL => "DesktopL",
    ScreenType.outOfRange => "OutOfRange",
  };


}