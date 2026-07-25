import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';

/// Convenience façade for [ResHelper].
///
/// Use [MyRes.instance] anywhere in your app — no [BuildContext] needed.
/// Use [MyRes.of(context)] when you want to also refresh the singleton
/// with the latest screen size.
class MyRes {
  MyRes._();

  /// The singleton [ResHelper] instance.
  ///
  /// Available as long as [ResInit] has mounted at least once.
  static ResHelper get instance => ResHelper.instance;

  /// Returns the singleton, optionally refreshing it from [context].
  static ResHelper of([BuildContext? context]) =>
      ResHelper.of(context: context);
}
