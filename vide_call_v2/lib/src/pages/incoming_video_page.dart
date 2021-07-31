import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vide_call_v2/models/call_remote_message.dart';
import 'package:vide_call_v2/src/pages/call/call_provider.dart';
import 'package:provider/provider.dart';
class InComingVideoPage extends StatefulWidget {
  final CallRemoteMessage callRemoteMessage;
  InComingVideoPage({this.callRemoteMessage});
  @override
  _InComingVideoPageState createState() => _InComingVideoPageState();
}

class _InComingVideoPageState extends State<InComingVideoPage> {

  CallProvider _callProvider;
  AudioPlayer audioPlayer ;
  AudioCache audioCache = AudioCache();
  @override
  initState(){
    super.initState();
    _callProvider=context.read();
    play();
  }

  play() async {
    audioPlayer=await audioCache.loop('sound.wav', mode: PlayerMode.LOW_LATENCY);


  }
  onPressAcceptCall() async{
    await audioPlayer?.stop();
    if(widget.callRemoteMessage!=null)
      {
        _callProvider.startVideoCallFromIncomingCall(context: context,channelName:widget.callRemoteMessage.callerId );
      }

  }
  onPressEndCall() async{
    await audioPlayer?.stop();
    await _callProvider.endCall();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Container()),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            widget.callRemoteMessage!=null?widget.callRemoteMessage.callerName:'',
            style: TextStyle(
                fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Incoming Video Call",
            style: TextStyle(fontSize: 20, color: Colors.green),
          ),
          Expanded(child: Container()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed:onPressEndCall,
                child: Icon(Icons.phone_disabled, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                  primary: Colors.red, // <-- Button color
                  onPrimary: Colors.red, // <-- Splash color
                ),
              ),
              ElevatedButton(
                onPressed: onPressAcceptCall,
                child: Icon(Icons.phone, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                  primary: Colors.green, // <-- Button color
                  onPrimary: Colors.green, // <-- Splash color
                ),
              )
            ],
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
