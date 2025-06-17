import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/plate_type.dart';
import 'package:res_reline/src/res_functions/res_context.dart';

part 'base_helper.dart';

part 'res_font.dart';

class ResHelper extends _BaseResHelper with  MyResFont  {
  static ResHelper? _instance;

  factory ResHelper.of({BuildContext? context}) {
    if(_instance==null &&context ==null) return throw ArgumentError("context can not be null");
    if(_instance!=null&&context!=null) {
      _instance!.resizer =MediaQuery.sizeOf(context);
    }
    _instance ??= ResHelper(context: context!);
    return _instance!;
  }

  factory ResHelper({
  required  BuildContext context,
    Size? mobSSize,
    Size? mobMSize,
    Size? mobLSize,
    Size? tabSSize,
    Size? tabMSize,
    Size? tabLSize,
    Size? deskSSize,
    Size? deskMSize,
    Size? deskLSize,
    BoxConstraints? constrains,
  }) {
    return ResHelper._(
      size: MediaQuery.sizeOf(context),
      mobSSize: mobSSize,
      mobMSize: mobMSize,
      mobLSize: mobLSize,
      tabSSize: tabSSize,
      tabMSize: tabMSize,
      tabLSize: tabLSize,
      deskSSize: deskSSize,
      deskMSize: deskMSize,
      deskLSize: deskLSize,
      constrains: constrains,
    );
  }

  ResHelper._({
   required super.size,
    super.mobSSize,
    super.mobMSize,
    super.mobLSize,
    super.tabSSize,
    super.tabMSize,
    super.tabLSize,
    super.deskSSize,
    super.deskMSize,
    super.deskLSize,
    super.constrains,
  }) : super._();

  /// functions
  T any<T>(T d, T t, T m, {T? mS, T? mL, T? mXL, T? tS, T? tL, T? dS, T? dL}) {
    if (isMobileS) return mS ?? m;
    if (isMobileM) return m;
    if (isMobileL) return mL ?? m;
    if (isTabletS) return tS ?? t;
    if (isTabletM) return t;
    if (isTabletL) return tL ?? t;
    if (isDesktopS) return dS ?? d;
    if (isDesktopM) return d;
    if (isDesktopL) return dL ?? d;
    return m;
  }

  double anySizeBetween(double s, double l) {
    final start = (l - s) / 9;
    final responsiveValue = switch (getPlat) {
      ResPlateType.isMobileS => start * 1,
      ResPlateType.isMobileM => start * 2,
      ResPlateType.isMobileL => start * 3,
      ResPlateType.isTabletS => start * 4,
      ResPlateType.isTabletM => start * 5,
      ResPlateType.isTabletL => start * 6,
      ResPlateType.isDesktopS => start * 7,
      ResPlateType.isDesktopM => start * 8,
      ResPlateType.isDesktopL => start * 9,
      ResPlateType.outOfRange => start * 9,
    };
    return (responsiveValue + width / 100).clamp(s, l);
  }

  double anyWidthBetween(double s, double l) {
    double responsiveValue = s + (l - s) * (width / getPlatSize.width);
    if (responsiveValue < s) responsiveValue = s;
    if (responsiveValue > l) responsiveValue = l;

    return responsiveValue;
  }

  double mediaWidthDTM(
    double d,
    double t,
    double m, {
    double? mS,
    double? mL,
    double? mXL,
    double? tS,
    double? tL,
    double? dS,
    double? dL,
  })
  {
    if (isMobileS) return width * (mS ?? m);
    if (isMobileM) return width * m;
    if (isMobileL) return width * (mL ?? m);
    if (isTabletS) return width * (tS ?? t);
    if (isTabletM) return width * t;
    if (isTabletL) return width * (tL ?? t);
    if (isDesktopS) return width * (dS ?? d);
    if (isDesktopM) return width * d;
    if (isDesktopL) {
      return width * (dL ?? d);
    } else {
      throw ("value must < or = 1");
    }
  }

  double mediaHeightDTM(
    double d,
    double t,
    double m, {
    double? mS,
    double? mL,
    double? mXL,
    double? tS,
    double? tL,
    double? dS,
    double? dL,
  }) {
    if (isMobileS) return height * (mS ?? m);
    if (isMobileM) return height * m;
    if (isMobileL) return height * (mL ?? m);
    if (isTabletS) return height * (tS ?? t);
    if (isTabletM) return height * t;
    if (isTabletL) return height * (tL ?? t);
    if (isDesktopS) return height * (dS ?? d);
    if (isDesktopM) return height * d;
    if (isDesktopL) {
      return height * (dL ?? d);
    } else {
      throw ("value must < or = 1");
    }
  }

  /* double aspectRatioDTM2(
      double d, double t, double m,
      {double? mS,
      double? mL,
      double? mXL,
      double? tS,
      double? tL,
      double? dS,
      double? dL}) {
    if (isMobileS) return aspectRatio * (mS ?? m);
    if (isMobileM) return aspectRatio * m;
    if (isMobileL) return aspectRatio * (mL ?? m);
    if (isTabletS) return aspectRatio * (tS ?? t);
    if (isTabletM) return aspectRatio * t;
    if (isTabletL) return aspectRatio * (tL ?? t);
    if (isDesktopS) return aspectRatio * (dS ?? d);
    if (isDesktopM) return aspectRatio * d;
    if (isDesktopL) return aspectRatio * (dL ?? d);
    return aspectRatio * m;
  }*/

  double aspectRatioDTM(
    double d,
    double t,
    double m, {
    double? mS,
    double? mL,
    double? mXL,
    double? tS,
    double? tL,
    double? dS,
    double? dL,
  }) {
    if (isMobileS) return width / getPlatSize.width * (mS ?? m);
    if (isMobileM) return width / getPlatSize.width * m;
    if (isMobileL) return width / getPlatSize.width * (mL ?? m);
    if (isTabletS) return width / getPlatSize.width * (tS ?? t);
    if (isTabletM) return width / getPlatSize.width * t;
    if (isTabletL) return width / getPlatSize.width * (tL ?? t);
    if (isDesktopS) return width / getPlatSize.width * (dS ?? d);
    if (isDesktopM) return width / getPlatSize.width * d;
    if (isDesktopL) return width / getPlatSize.width * (dL ?? d);
    return size.width / getPlatSize.width * m;
  }

  T? viewIfWidthGreatThan<T>({
    required double width,
    required T child,
    T? elseChild,
  }) => this.width >= width ? child : elseChild;

  T? viewIfWidthLessThan<T>({
    required double width,
    required T child,
    T? elseChild,
  }) => this.width <= width ? child : elseChild;

  T? viewIfEqualPlat<T>({
    required ResPlateType platType,
    required T child,
    T? elseChild,
  }) => getPlat == platType ? child : elseChild;

  double padding(double v) {
    return switch (getPlat) {
      ResPlateType.isMobileS => width * v / 1000,
      ResPlateType.isMobileM => width * v / 1000,
      ResPlateType.isMobileL => width * v / 900,
      ResPlateType.isTabletS => width * v / 700,
      ResPlateType.isTabletM => width * v / 600,
      ResPlateType.isTabletL => width * v / 550,
      ResPlateType.isDesktopS => width * v / 500,
      ResPlateType.isDesktopM => width * v / 450,
      ResPlateType.isDesktopL => width * v / 400,
      ResPlateType.outOfRange => width * v / 400,
    };
  }
}
