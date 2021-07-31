import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';

import 'call_kit_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    CallKitManager.instance.init(onCallAccepted: onCallAccepted, onCallEnded: onCallEnded);
  }
  onCallAccepted( uuid){

  }
  onCallEnded( uuid){

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ElevatedButton(onPressed: (){
            Set<int> opponentsIds={};
            opponentsIds.add(2);
            ConnectycubeFlutterCallKit.showCallNotification(sessionId: "1", callType: 1, callerId: 2, callerName: "trong", opponentsIds: opponentsIds);
          },child: Text("Show call video"),),
        ),
      ),
    );
  }
}
