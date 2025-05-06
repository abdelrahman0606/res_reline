import 'package:flutter/material.dart';
import 'package:res_reline/src/res_functions/main_helper.dart';

class MyRes {
  MyRes._();
  static ResHelper of([BuildContext? context]) => ResHelper.of(context: context);

  static void init({
    BuildContext? context,
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
  }) => ResHelper.init(
    context: context,
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

  static ResHelper instance({
    BuildContext? context,
    Size? size,
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
  }) => ResHelper(
    context: context,
    constrains: constrains,
    mobSSize: mobSSize ,
    mobMSize: mobMSize ,
    mobLSize: mobLSize ,
    tabSSize: tabSSize ,
    tabMSize: tabMSize ,
    tabLSize: tabLSize ,
    deskSSize: deskSSize ,
    deskMSize: deskMSize ,
    deskLSize: deskLSize,
  )..resize = size;
}
