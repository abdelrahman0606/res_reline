import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/plate_type.dart';


class ResLayoutData {
  final ScreenType screenType;
  final double width;
  final double height;
  final double mobileBreakpoint;
  final double desktopBreakpoint;

  const ResLayoutData({
    required this.screenType,
    required this.width,
    required this.height,
    required this.mobileBreakpoint,
    required this.desktopBreakpoint,
  });

  bool get isMobile => screenType == ScreenType.mobileM;
  bool get isTablet => screenType == ScreenType.tabletM;
  bool get isDesktop => screenType == ScreenType.desktopM;
}

class _ResLayoutInherited extends InheritedWidget {
  final ResLayoutData data;

  const _ResLayoutInherited({
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ResLayoutInherited oldWidget) {
    return data.screenType != oldWidget.data.screenType ||
        data.width != oldWidget.data.width ||
        data.height != oldWidget.data.height;
  }
}

class ResLayoutBreak extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints) desktop;
  final double mobileBreakpoint;
  final double desktopBreakpoint;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;

  const ResLayoutBreak({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.mobileBreakpoint = 600,
    this.desktopBreakpoint = 1024,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : assert(mobileBreakpoint < desktopBreakpoint);

  static ResLayoutData of(BuildContext context, {
    double mobileBreakpoint = 600,
    double desktopBreakpoint = 1024,
  }) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_ResLayoutInherited>();
    if (inherited != null) {
      return inherited.data;
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final screenType = _getScreenTypeStatic(width, mobileBreakpoint, desktopBreakpoint);

    return ResLayoutData(
      screenType: screenType,
      width: width,
      height: height,
      mobileBreakpoint: mobileBreakpoint,
      desktopBreakpoint: desktopBreakpoint,
    );
  }

  static ScreenType _getScreenTypeStatic(double width, double mobileBreakpoint, double desktopBreakpoint) {
    if (width < mobileBreakpoint) {
      return ScreenType.mobileM;
    } else if (width < desktopBreakpoint) {
      return ScreenType.tabletM;
    } else {
      return ScreenType.desktopM;
    }
  }

  ScreenType _getScreenType(double width) {
    if (width < mobileBreakpoint) {
      return ScreenType.mobileM;
    } else if (width < desktopBreakpoint) {
      return ScreenType.tabletM;
    } else {
      return ScreenType.desktopM;
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final screenType = _getScreenType(width);

        final data = ResLayoutData(
          screenType: screenType,
          width: width,
          height: height,
          mobileBreakpoint: mobileBreakpoint,
          desktopBreakpoint: desktopBreakpoint,
        );

        final Widget layout;
        if (screenType == ScreenType.mobileM) {
          layout = mobile(context, constraints);
        } else if (screenType == ScreenType.tabletM) {
          layout = tablet?.call(context, constraints) ?? desktop(context, constraints);
        } else {
          layout = desktop(context, constraints);
        }

        return _ResLayoutInherited(
          data: data,
          child: layout,
        );
      },
    );

    if (animate) {
      return AnimatedSize(
        duration: animationDuration,
        curve: animationCurve,
        alignment: Alignment.topCenter,
        child: child,
      );
    }

    return child;
  }
}

class ResValue<T> extends StatelessWidget {
  final T mobile;
  final T? tablet;
  final T desktop;
  final Widget Function(BuildContext context, T value) builder;
  final double mobileBreakpoint;
  final double desktopBreakpoint;

  const ResValue({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    required this.builder,
    this.mobileBreakpoint = 600,
    this.desktopBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final T value;

        if (width < mobileBreakpoint) {
          value = mobile;
        } else if (width < desktopBreakpoint) {
          value = tablet ?? desktop;
        } else {
          value = desktop;
        }

        return builder(context, value);
      },
    );
  }
}

