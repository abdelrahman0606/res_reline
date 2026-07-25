enum ScreenType {
  mobileS,
  mobileM,
  mobileL,
  tabletS,
  tabletM,
  tabletL,
  desktopS,
  desktopM,
  desktopL,
  outOfRange,
}

extension PlatTypeEx on ScreenType {
  String get toMap => switch (this) {
    ScreenType.mobileS => "MobileS",
    ScreenType.mobileM => "MobileM",
    ScreenType.mobileL => "MobileL",
    ScreenType.tabletS => "TabletS",
    ScreenType.tabletM => "TabletM",
    ScreenType.tabletL => "TabletL",
    ScreenType.desktopS => "DesktopS",
    ScreenType.desktopM => "DesktopM",
    ScreenType.desktopL => "DesktopL",
    ScreenType.outOfRange => "OutOfRange",
  };
}