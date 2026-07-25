import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:res_reline/my_responsive.dart';

import 'example/main.dart';

void main() {
  debugRepaintRainbowEnabled = true;
  runApp(
    const ResInit(
      designSize: Size(375, 812),
      child: MyApp(),
    ),
  );
}

