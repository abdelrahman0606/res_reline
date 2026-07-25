import 'package:flutter/material.dart';
import 'package:res_reline/example/res_page_sizer_example.dart';
import '../my_responsive.dart';
import 'screen1.dart';




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("build app");
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ResPageSizerExample(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // rs.resize = MediaQuery.sizeOf(context) *0.5;

    print("build home");
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
              style: TextStyle(),
            ),
            Expanded(
              child: Container(
                color: Colors.grey,
                padding: EdgeInsetsDirectional.all(10),
                child: ResBodySide(
                  defaultBodyWidth: 0.5,
                  minSideWidth: 0.2,
                  minBodyWidth: 0.2,
                  hideSide: true,
                  body: ResPageSizer(
                    builder:
                        (context, constraints, rs) => Row(
                          children: [
                            _container(rs),
                          ],
                        ),
                  ),
                  side: ResPageSizer(
                    builder:
                        (context, constraints, rs) => _container(rs),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => Screen1()),
                // );
              },
              child: Text("Go to screen 1"),
            ),
          ],
        ),
      ),
    );
  }

Widget _container(ResHelper rs) => Container(
  color: Colors.red,
  width: rs.setWidth(100),
  height: rs.setHeight(100),
  child: Text(
    rs.any(
      dL: "Desktop Large",
      "Desktop",
      dS: "Desktop Small",
      tL: "Tablet Large",
      "Tablet",
      tS:"Tablet Small" ,
      mL: "Mobile Large",
      "Mobile",
      mS: "Mobile Small",
    ),
  ),
);
}
