import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';
import 'main_responsive.dart';

class ResLayout extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  mobileS;
  final Widget Function(BuildContext context, BoxConstraints constraints)
  mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  mobileL;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  tabletS;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  tabletL;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  desktopS;
  final Widget Function(BuildContext context, BoxConstraints constraints)
  desktop;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  desktopL;
  final bool enablePrint;
  final ResHelper? res;

  const ResLayout({
    super.key,
    required this.mobile,
    this.mobileS,
    this.mobileL,
    this.tablet,
    this.tabletS,
    this.tabletL,
    required this.desktop,
    this.desktopS,
    this.desktopL,
    this.enablePrint = false,
    this.res,
  });

  Widget? _mobile(context, constraints) {
    final rs = res ?? MyRes.of(context);
    if (rs.isMobileS) {
      return mobileS?.call(context, constraints) ??
          mobile.call(context, constraints);
    }
    if (rs.isMobileL) {
      return mobileL?.call(context, constraints) ??
          mobile.call(context, constraints);
    }
    if (rs.isMobileM) return mobile.call(context, constraints);
    return null;
  }

  Widget? _tablet(context, constraints) {
    final rs = res ?? MyRes.of(context);

    if (rs.isTabletS) {
      return tabletS?.call(context, constraints) ??
          tablet?.call(context, constraints) ??
          desktop.call(context, constraints);
    }
    if (rs.isTabletL) {
      return tabletL?.call(context, constraints) ??
          tablet?.call(context, constraints) ??
          desktop.call(context, constraints);
    }
    if (rs.isTabletM) {
      return tablet?.call(context, constraints) ??
          desktop.call(context, constraints);
    }
    return null;
  }

  Widget? _desktop(context, constraints) {
    final rs = res ?? MyRes.of(context);

    if (rs.isDesktopS) {
      return desktopS?.call(context, constraints) ??
          desktop.call(context, constraints);
    }
    if (rs.isDesktopL) {
      return desktopL?.call(context, constraints) ??
          desktop.call(context, constraints);
    }
    if (rs.isDesktopM) return desktop.call(context, constraints);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (enablePrint) {
            final rs = res ?? MyRes.of(context);

            rs.aiPrinter;
          }
          return _mobile(context, constraints) ??
              _tablet(context, constraints) ??
              _desktop(context, constraints) ??
              mobile(context, constraints);
        },
      ),
    );
  }
}
