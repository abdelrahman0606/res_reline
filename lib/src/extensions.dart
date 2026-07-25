import 'dart:math';
import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';

// ─── num extensions ─────────────────────────────────────────────────────────

extension SizeExtension on num {
  // ── Scaling ──────────────────────────────────────────────────────────────

  /// Scale by design width  (baseWidth = 375).
  double get w => ResHelper.instance.setWidth(toDouble());

  /// Scale by design height for layout (baseHeightForSetHeight = 700).
  double get setH => ResHelper.instance.setHeight(toDouble());

  /// Scale by screen height for fonts/proportions (baseHeight = 812).
  double get h => ResHelper.instance.h(toDouble());
  double get s => ResHelper.instance.h(toDouble());
  double get r => ResHelper.instance.r(toDouble());

  /// Scale as a font size.
  double get sp => ResHelper.instance.setSp(toDouble());

  /// Minimum of the raw value and the scaled font size.
  double get spMin => min(toDouble(), sp);

  // ── Responsive range helpers ─────────────────────────────────────────────

  /// Returns a value interpolated between [this] (small) and [to] (large)
  /// based on the current breakpoint.
  double to(double to) => ResHelper.instance.anySizeBetween(toDouble(), to);

  /// Alias — interpolates between [from] (small) and [this] (large).
  double from(double from) =>
      ResHelper.instance.anySizeBetween(from, toDouble());

  // ── Padding helpers ──────────────────────────────────────────────────────

  /// Responsive horizontal padding (uses [ResHelper.padding]).
  double get ph => ResHelper.instance.padding(toDouble());

  /// Symmetric horizontal [EdgeInsetsDirectional].
  EdgeInsetsDirectional get pdh =>
      EdgeInsetsDirectional.symmetric(horizontal: toDouble());

  /// Symmetric vertical [EdgeInsetsDirectional].
  EdgeInsetsDirectional get pdv =>
      EdgeInsetsDirectional.symmetric(vertical: toDouble());

  /// Symmetric on both axes [EdgeInsetsDirectional].
  EdgeInsetsDirectional get pdAll => EdgeInsetsDirectional.all(toDouble());
}

// ─── BorderRadius extensions ─────────────────────────────────────────────────

extension BorderRadiusExtension on BorderRadius {
  /// Scales each corner radius by width.
  BorderRadius get w => copyWith(
    bottomLeft: bottomLeft.w,
    bottomRight: bottomRight.w,
    topLeft: topLeft.w,
    topRight: topRight.w,
  );

  /// Scales each corner radius by height.
  BorderRadius get h => copyWith(
    bottomLeft: bottomLeft.h,
    bottomRight: bottomRight.h,
    topLeft: topLeft.h,
    topRight: topRight.h,
  );
}

// ─── Radius extensions ───────────────────────────────────────────────────────

extension RadiusExtension on Radius {
  /// Scales both elliptical values by width.
  Radius get w => Radius.elliptical(
    ResHelper.instance.setWidth(x),
    ResHelper.instance.setWidth(y),
  );

  /// Scales both elliptical values by height.
  Radius get h => Radius.elliptical(
    ResHelper.instance.setHeight(x),
    ResHelper.instance.setHeight(y),
  );
}

// ─── BoxConstraints extensions ───────────────────────────────────────────────

extension BoxConstraintsExtension on BoxConstraints {
  /// Scales all four bounds by width.
  BoxConstraints get w => copyWith(
    maxHeight: ResHelper.instance.setWidth(maxHeight),
    maxWidth: ResHelper.instance.setWidth(maxWidth),
    minHeight: ResHelper.instance.setWidth(minHeight),
    minWidth: ResHelper.instance.setWidth(minWidth),
  );

  /// Scales all four bounds by height.
  BoxConstraints get h => copyWith(
    maxHeight: ResHelper.instance.setHeight(maxHeight),
    maxWidth: ResHelper.instance.setHeight(maxWidth),
    minHeight: ResHelper.instance.setHeight(minHeight),
    minWidth: ResHelper.instance.setHeight(minWidth),
  );

  /// Scales width bounds by width and height bounds by height.
  BoxConstraints get hw => copyWith(
    maxHeight: ResHelper.instance.setHeight(maxHeight),
    maxWidth: ResHelper.instance.setWidth(maxWidth),
    minHeight: ResHelper.instance.setHeight(minHeight),
    minWidth: ResHelper.instance.setWidth(minWidth),
  );
}

// ─── Size extensions ─────────────────────────────────────────────────────────

extension SizeEx on Size {
  Size add(double w, double h) => Size(width + w, height + h);
  Size sub(double w, double h) => Size(width - w, height - h);
  Size addWidth(double w) => Size(width + w, height);
  Size subWidth(double w) => Size(width - w, height);
}
