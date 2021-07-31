import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vide_call_v2/services/video_call_manager.dart';
import 'package:vide_call_v2/utils/settings.dart';

import 'package:provider/provider.dart';

import 'call_provider.dart';

class CallPage extends StatefulWidget {
  // /// non-modifiable channel name of the page
  // final String channelName;
  //
  // /// non-modifiable client role of the page
  // final ClientRole role;

  final bool isCall;

  /// Creates a call page with given channel name.
  const CallPage({Key key,this.isCall}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  // final _users = <int>[];
  // final _infoStrings = <String>[];

  CallProvider _callProvider;
  bool muted = false;
   // RtcEngine _engine;
  AudioPlayer audioPlayer ;
  AudioCache audioCache = AudioCache();
  bool startCall=true;
  @override
  void initState() {
    super.initState();
    _callProvider=context.read();
    playRing();
  }
  @override
  void dispose() {

    stopRing();
    _callProvider.endCall();
    super.dispose();

  }

  @override
  void didChangeDependencies() {
    List<int>nextUsers= context.watch<CallProvider>().users;

    print('didChangeDependencies(), nextUsers length = ${nextUsers.length.toString()}');
    if(nextUsers.length>0)
      {
        startCall=false;
        stopRing();

      }
    if(nextUsers.length==0)
      {
        if(startCall==false)
          {
            _onCallEnd(context);
          }
      }
    super.didChangeDependencies();
  }

  playRing() async {

    if(Platform.isAndroid && widget.isCall==true)
      {
        audioPlayer=await audioCache.loop('audit.mp3');
      }



  }
  stopRing()async{

    if(Platform.isAndroid)
    {
      await audioPlayer?.stop();
    }

  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }


  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    // if (widget.role == ClientRole.Broadcaster) {
    //   list.add(RtcLocalView.SurfaceView());
    // }
    list.add(RtcLocalView.SurfaceView());


    context.watch<CallProvider>().users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
              children: <Widget>[_videoView(views[0])],
            ));
      case 2:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow([views[0]]),
                _expandedVideoRow([views[1]])
              ],
            ));
      case 3:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 3))
              ],
            ));
      case 4:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 4))
              ],
            ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget  _toolbar() {
    // if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Selector<CallProvider, List<String>>(
            shouldRebuild: (List<String> newList,List<String> oldList)
              {
                return newList!=oldList || newList.length!=oldList.length;
              },
            selector: (_, provider) => provider.infoStrings,
            builder: (_,  List<String> infoStrings, __) {
              print("infoStrings length "+infoStrings.length.toString());
              return ListView.builder(
                reverse: true,
                itemCount: infoStrings.length,
                itemBuilder: (BuildContext context, int index) {
                  if (infoStrings.isEmpty) {
                    return Text("null");  // return type can't be null, a widget was required
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.yellowAccent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              infoStrings[index],
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }

          ),
        ),
      ),
    );
  }



  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    VideoCallManager.instance.engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    VideoCallManager.instance.engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agora Flutter QuickStart'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
