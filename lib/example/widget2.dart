
import 'package:flutter/material.dart';
import 'package:res_reline/my_responsive.dart';

class Widget2 extends StatefulWidget {
  const Widget2({super.key});

  @override
  State<Widget2> createState() => _Widget2State();
}

class _Widget2State extends State<Widget2> {
  @override
  Widget build(BuildContext context) {
    final rs =  MyRes.instance(context: context,
    size: MediaQuery.sizeOf(context) *0.5,
    mobLSize: Size(600, 600),
    deskMSize: Size(600, 600) ,
    tabLSize: Size(600, 600),
    deskSSize: Size(600, 600),
    mobMSize: Size(600, 600) ,
    tabSSize: Size(600, 600),
    mobSSize: Size(600, 600),
    tabMSize: Size(600, 600),
     deskLSize: Size(600, 600),
    )..resize =MediaQuery.sizeOf(context) *0.5;
  print("build widget 2");
    return Column(
      children: [
        Container(
          color: Colors.red,
          height:rs.height*0.2,
          width: rs.any(400, 200, 100),
        ),
        Text("Widget 2", style: TextStyle(fontSize: 16.sp),),
      ],
    );
  }
}
