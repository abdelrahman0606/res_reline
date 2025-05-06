import 'package:flutter/material.dart';
import 'package:res_reline/my_responsive.dart';

import 'widget1.dart';
import 'widget2.dart';
class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 1'),
      ),
      body:  Center(
        child: Column(
          children: [
            Widget1(),
            Widget2(),
            Text('Screen 1', style: TextStyle(fontSize: 16.sp),),
          ],
        ),
      ),
    );
  }
}
