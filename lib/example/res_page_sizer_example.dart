import 'package:flutter/material.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:res_reline/src/res_functions/plate_type.dart';

class ResPageSizerExample extends StatefulWidget {
  const ResPageSizerExample({super.key});

  @override
  State<ResPageSizerExample> createState() => _ResPageSizerExampleState();
}

class _ResPageSizerExampleState extends State<ResPageSizerExample> {
  bool spiltScreen =false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(spiltScreen?"Spilt Screen":"One Screen"),
      actions: [
        TextButton(onPressed: () {
        setState(() {
          spiltScreen = !spiltScreen;
        });
      }, child:Text(spiltScreen?"One Screen":"Spilt Screen"),),
      ],
      ),
      body: spiltScreen? ResLayout(
        mobile: (context, constraints) => _bodyWidget(),
        tablet: (context, constraints) => Row(
              children: [
                SizedBox(
                    width: 150,
                    child: _sideWidget(Colors.amber)),
                Expanded(flex: 2, child: _bodyWidget()),
              ],
            ),
        desktop: (context, constraints) => Row(
              children: [
                SizedBox(
                    width: 300,
                    child: _sideWidget(Colors.orange)),
                Expanded(flex: 2, child: _bodyWidget()),
              ],
            ),
      ):_bodyWidget(),
    );
  }

  Widget _sideWidget(Color color) => Container(
      height: double.infinity,
      width: double.infinity,
      color: color);

  Widget _bodyWidget() => ResPageSizer(
    builder:
        (context, constraints, rs) => Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.blue,
          child: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${rs.plat.toMap}\n${rs.platSize.toString()}"),
              Container(
                width: rs.any(100, 80, 50),
                height:rs.any(100, 80, 50),
                color: Colors.red,
              )
            ],
          )),
        ),
  );
}
