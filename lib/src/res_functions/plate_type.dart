enum ResPlateType {
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
extension PlatTypeEx on ResPlateType {
  String get toMap => switch (this) {
    ResPlateType.isMobileS => "MobileS",
    ResPlateType.isMobileM => "MobileM",
    ResPlateType.isMobileL => "MobileL",
    ResPlateType.isTabletS => "TabletS",
    ResPlateType.isTabletM => "TabletM",
    ResPlateType.isTabletL => "TabletL",
    ResPlateType.isDesktopS => "DesktopS",
    ResPlateType.isDesktopM => "DesktopM",
    ResPlateType.isDesktopL => "DesktopL",
    ResPlateType.outOfRange => "OutOfRange",
  };


}