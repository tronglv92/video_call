

import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("vao trong TestPage");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Text("Test page"),
      ),
    );
  }
}
