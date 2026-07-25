import 'dart:math';

import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/plate_type.dart';

part 'base_helper.dart';
part 'res_font.dart';

/// The single global instance of [ResHelper].
///
/// Populated by [ResInit] before any extension is used.
/// Accessible anywhere via `ResHelper.instance`.
class ResHelper extends _BaseResHelper with MyResFont {
  // ─── Singleton ──────────────────────────────────────────────────────────

  ResHelper._({
    super.size,
    super.mobSSize,
    super.mobMSize,
    super.mobLSize,
    super.tabSSize,
    super.tabMSize,
    super.tabLSize,
    super.deskSSize,
    super.deskMSize,
    super.deskLSize,
    super.constraints,
  }) : super._();

  static final ResHelper _instance = ResHelper._();

  /// The singleton instance.
  ///
  /// Use this in extensions and anywhere you need calculations
  /// without a [BuildContext].
  static ResHelper get instance => _instance;

  /// Returns the singleton, optionally refreshing the cached size from
  /// the given [context].
  ///
  /// Prefer [instance] when you don't have a context.
  static ResHelper of({BuildContext? context}) {
    if (context != null) {
      configure(MediaQuery.sizeOf(context));
    } else if (_instance.size == null) {
      throw StateError(
        'ResHelper has not been initialised yet.\n'
        'Wrap your app with ResInit(...) before using '
        'context-free extensions.',
      );
    }
    return _instance;
  }

  // ─── Configuration ──────────────────────────────────────────────────────

  /// Called by [ResInit] whenever the screen size changes.
  ///
  /// Stores only the [Size] — never a [BuildContext].
  static void configure(
    Size size, {
    Size designSize = const Size(375, 812),
    double? scaleFraction,
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
  }) {
    _instance.size = size;
    _instance._designSize = designSize;
    _instance._designHeightForLayout = designSize.height * (700 / 812);
    if (scaleFraction != null) _instance._scaleFraction = scaleFraction;
    if (mobSSize != null) _instance.mobSSize = mobSSize;
    if (mobMSize != null) _instance.mobMSize = mobMSize;
    if (mobLSize != null) _instance.mobLSize = mobLSize;
    if (tabSSize != null) _instance.tabSSize = tabSSize;
    if (tabMSize != null) _instance.tabMSize = tabMSize;
    if (tabLSize != null) _instance.tabLSize = tabLSize;
    if (deskSSize != null) _instance.deskSSize = deskSSize;
    if (deskMSize != null) _instance.deskMSize = deskMSize;
    if (deskLSize != null) _instance.deskLSize = deskLSize;
    if (constraints != null) _instance.constraintsMutable = constraints;
  }

  // ─── Per-widget overrides ────────────────────────────────────────────────

  /// Creates a scoped helper bound to specific [constraints] or a known
  /// [screenSize] — useful inside [LayoutBuilder] callbacks.
  factory ResHelper.scoped({
    required Size screenSize,
    BoxConstraints? constraints,
    Size? mobSSize,
    Size? mobMSize,
    Size? mobLSize,
    Size? tabSSize,
    Size? tabMSize,
    Size? tabLSize,
    Size? deskSSize,
    Size? deskMSize,
    Size? deskLSize,
  }) {
    return ResHelper._(
      size: screenSize,
      constraints: constraints,
      mobSSize: mobSSize,
      mobMSize: mobMSize,
      mobLSize: mobLSize,
      tabSSize: tabSSize,
      tabMSize: tabMSize,
      tabLSize: tabLSize,
      deskSSize: deskSSize,
      deskMSize: deskMSize,
      deskLSize: deskLSize,
    );
  }

  // ─── Functions ───────────────────────────────────────────────────────────

  T any<T>(T d, T t, T m, {T? mS, T? mL, T? mXL, T? tS, T? tL, T? dS, T? dL}) {
    return switch (plat) {
      ScreenType.mobileS => mS ?? m,
      ScreenType.mobileM => m,
      ScreenType.mobileL => mL ?? m,
      ScreenType.tabletS => tS ?? t,
      ScreenType.tabletM => t,
      ScreenType.tabletL => tL ?? t,
      ScreenType.desktopS => dS ?? d,
      ScreenType.desktopM => d,
      ScreenType.desktopL => dL ?? d,
      ScreenType.outOfRange => d,
    };
  }

  double anySizeBetween(double s, double l) {
    final start = (l - s) / 9;
    final responsiveValue = switch (plat) {
      ScreenType.mobileS => start * 1,
      ScreenType.mobileM => start * 2,
      ScreenType.mobileL => start * 3,
      ScreenType.tabletS => start * 4,
      ScreenType.tabletM => start * 5,
      ScreenType.tabletL => start * 6,
      ScreenType.desktopS => start * 7,
      ScreenType.desktopM => start * 8,
      ScreenType.desktopL => start * 9,
      ScreenType.outOfRange => start * 9,
    };
    return (responsiveValue + width / 100).clamp(s, l);
  }

  double anyWidthBetween(double s, double l) {
    double responsiveValue = s + (l - s) * (width / platSize.width);
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
  }) {
    final multiplier = switch (plat) {
      ScreenType.mobileS => mS ?? m,
      ScreenType.mobileM => m,
      ScreenType.mobileL => mL ?? m,
      ScreenType.tabletS => tS ?? t,
      ScreenType.tabletM => t,
      ScreenType.tabletL => tL ?? t,
      ScreenType.desktopS => dS ?? d,
      ScreenType.desktopM => d,
      ScreenType.desktopL => dL ?? d,
      ScreenType.outOfRange => throw ('value must < or = 1'),
    };
    return width * multiplier;
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
    final multiplier = switch (plat) {
      ScreenType.mobileS => mS ?? m,
      ScreenType.mobileM => m,
      ScreenType.mobileL => mL ?? m,
      ScreenType.tabletS => tS ?? t,
      ScreenType.tabletM => t,
      ScreenType.tabletL => tL ?? t,
      ScreenType.desktopS => dS ?? d,
      ScreenType.desktopM => d,
      ScreenType.desktopL => dL ?? d,
      ScreenType.outOfRange => throw ('value must < or = 1'),
    };
    return height * multiplier;
  }

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
    final multiplier = switch (plat) {
      ScreenType.mobileS => mS ?? m,
      ScreenType.mobileM => m,
      ScreenType.mobileL => mL ?? m,
      ScreenType.tabletS => tS ?? t,
      ScreenType.tabletM => t,
      ScreenType.tabletL => tL ?? t,
      ScreenType.desktopS => dS ?? d,
      ScreenType.desktopM => d,
      ScreenType.desktopL => dL ?? d,
      ScreenType.outOfRange => m,
    };
    return (width / platSize.width) * multiplier;
  }

  T? viewIfWidthGreaterThan<T>({
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
    required ScreenType platType,
    required T child,
    T? elseChild,
  }) => plat == platType ? child : elseChild;

  double padding(double v) {
    final divisor = switch (plat) {
      ScreenType.mobileS => 1000.0,
      ScreenType.mobileM => 1000.0,
      ScreenType.mobileL => 900.0,
      ScreenType.tabletS => 700.0,
      ScreenType.tabletM => 600.0,
      ScreenType.tabletL => 550.0,
      ScreenType.desktopS => 500.0,
      ScreenType.desktopM => 450.0,
      ScreenType.desktopL => 400.0,
      ScreenType.outOfRange => 400.0,
    };
    return width * v / divisor;
  }
}
