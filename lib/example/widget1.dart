//
// import 'package:flutter/material.dart';
// import 'package:res_reline/my_responsive.dart';
//
// class Widget1 extends StatefulWidget {
//   const Widget1({super.key});
//
//   @override
//   State<Widget1> createState() => _Widget1State();
// }
//
// class _Widget1State extends State<Widget1> {
//   final rs = MyRes.instance(
//       mobSSize: Size(300, 300),
//       tabSSize: Size(300, 300),
//       tabMSize: Size(300, 300) ,
//       mobMSize: const Size(300, 200),
//       deskSSize: const Size(300, 200),
//       deskMSize: const Size(300, 200));
//
//   @override
//   Widget build(BuildContext context) {
//     MyRes.init(context: context);
//
//     print("build widget 1");
//
//     return Column(
//       children: [
//         AnimatedScale(scale: 2, duration: Duration(milliseconds: 10000),
//
//         child: Text("data"),
//         ),
//         Container(
//           color: Colors.red,
//           height:rs.height*0.2,
//           width: rs.any(400, 200, 100),
//         ),
//         Text("Widget 1", style: TextStyle(fontSize: 16.sp),),
//       ],
//     );
//   }
// }
