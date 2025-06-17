// import 'package:flutter/material.dart';
// import 'package:res_reline/my_responsive.dart';
//
// import 'screen2.dart';
// import 'widget1.dart';
// import 'widget2.dart';
// class Screen1 extends StatefulWidget {
//   const Screen1({super.key});
//
//   @override
//   State<Screen1> createState() => _Screen1State();
// }
//
// class _Screen1State extends State<Screen1> {
//   @override
//   Widget build(BuildContext context) {
//     MyRes.of(context);
//     print("build screen 1");
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Screen 1'),
//       ),
//       body:  Center(
//         child: Column(
//           children: [
//             Widget1(),
//             Widget2(),
//             TextButton(onPressed: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => Screen2(),));
//             }, child: Text("Go to screen 2")),
//             Text('Screen 1', style: TextStyle(fontSize: 16.sp),),
//           ],
//         ),
//       ),
//     );
//   }
// }
