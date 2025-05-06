import 'dart:math';
import 'package:flutter/material.dart';
import 'main_responsive.dart';

extension SizeExtension on num {
  static BuildContext? context;
  double  to(context,double to) => MyRes.of(context).anySizeBetween(toDouble(), to);
  double  from(context,double from) => MyRes.of(context).anySizeBetween(toDouble(), from);
  double  ph(context) => MyRes.of(context).padding(toDouble());


  ///padding
  EdgeInsetsDirectional get pdh => EdgeInsetsDirectional.symmetric(horizontal: toDouble());
  EdgeInsetsDirectional get pdv => EdgeInsetsDirectional.symmetric(vertical: toDouble());
  EdgeInsetsDirectional get pdh__pdv => EdgeInsetsDirectional.symmetric(vertical: toDouble());


  double get w => MyRes.of().setWith(toDouble());

  double get h => MyRes.of().setHeight(toDouble());

  double get r => toDouble();


  double get sp => MyRes.of().setSp(toDouble());

  double get spMin => min(toDouble(), sp);
}

extension BorderRaduisExtension on BorderRadius {
  /// Creates adapt BorderRadius using r [SizeExtension].
  BorderRadius get r => copyWith(
        bottomLeft: bottomLeft.r,
        bottomRight: bottomRight.r,
        topLeft: topLeft.r,
        topRight: topRight.r,
      );

  BorderRadius get w => copyWith(
        bottomLeft: bottomLeft.w,
        bottomRight: bottomRight.w,
        topLeft: topLeft.w,
        topRight: topRight.w,
      );

  BorderRadius get h => copyWith(
        bottomLeft: bottomLeft.h,
        bottomRight: bottomRight.h,
        topLeft: topLeft.h,
        topRight: topRight.h,
      );
}

extension RaduisExtension on Radius {
  /// Creates adapt Radius using r [SizeExtension].
  Radius get r => Radius.elliptical(x.r, y.r);

  Radius get w => Radius.elliptical(x.w, y.w);

  Radius get h => Radius.elliptical(x.h, y.h);
}

extension BoxConstraintsExtension on BoxConstraints {
  /// Creates adapt BoxConstraints using r [SizeExtension].
  BoxConstraints get r => copyWith(
        maxHeight: maxHeight.r,
        maxWidth: maxWidth.r,
        minHeight: minHeight.r,
        minWidth: minWidth.r,
      );

  /// Creates adapt BoxConstraints using h-w [SizeExtension].
  BoxConstraints get hw => copyWith(
        maxHeight: maxHeight.h,
        maxWidth: maxWidth.w,
        minHeight: minHeight.h,
        minWidth: minWidth.w,
      );

  BoxConstraints get w => copyWith(
        maxHeight: maxHeight.w,
        maxWidth: maxWidth.w,
        minHeight: minHeight.w,
        minWidth: minWidth.w,
      );

  BoxConstraints get h => copyWith(
        maxHeight: maxHeight.h,
        maxWidth: maxWidth.h,
        minHeight: minHeight.h,
        minWidth: minWidth.h,
      );
}
extension SizeEx on Size {
  Size  add(width,height) =>Size(this.width+width,this.height+height);
  Size  sub(width,height) =>Size(this.width-width,this.height-height);
  Size  addWidth(width) =>Size(this.width+width,height);
  Size  subWidth(width) =>Size(this.width-width,height);

}
