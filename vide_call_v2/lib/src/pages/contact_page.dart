import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_call_kit/flutter_call_kit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:vide_call_v2/models/call_remote_message.dart';
import 'package:vide_call_v2/models/call_response.dart';
import 'package:vide_call_v2/services/call_kit_manager.dart';
import 'package:vide_call_v2/services/video_call_manager.dart';
import 'package:vide_call_v2/src/pages/call/call_provider.dart';
import 'package:vide_call_v2/src/pages/test_page.dart';
import 'package:vide_call_v2/utils/app_route.dart';
import 'package:vide_call_v2/utils/settings.dart';

import '../../main.dart';
import 'call/call_page.dart';
import 'incoming_video_page.dart';
import 'package:vide_call_v2/utils/navigator_state_extension.dart';
import 'package:provider/provider.dart';

class ContactPage extends StatefulWidget {
  final FlutterCallkeep callKeep;
  final Map<String, CallResponse> calls;

  ContactPage({this.callKeep, this.calls});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> with WidgetsBindingObserver {
  String _token;

  Uuid uuid = Uuid();

  CallProvider _callProvider;
  String channelName;
  @override
  void initState() {
    super.initState();
    _callProvider=context.read();

    WidgetsBinding.instance?.addObserver(this);
    _requestPermissionsLocalNotification();
    CallKitManager.instance.init(
        onCallAccepted: onCallAccepted,
        onCallEnded: onCallEnded,
        onNewCallShown: onNewCallShown,
        onMuteCall: onMuteCall);

    //Firebase and android CallKit

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      //message.data

      if (message != null) {
        // Navigator.pushNamed(context, '/message',
        //     arguments: MessageArguments(message, true));

      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // {
      //   "uuid": "xxxxx-xxxxx-xxxxx-xxxxx",
      // "caller_id": "+8618612345678",
      // "caller_name": "hello",
      // "caller_id_type": "number",
      // "has_video": false,
      // }
      print('A new message ');

      if (message.data["type"] == "video_call") {
        CallRemoteMessage callRemoteMessage =
            CallRemoteMessage.fromJson(message.data);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InComingVideoPage(
              callRemoteMessage: callRemoteMessage,
            ),
          ),
        );
      } else {
        _showNotification();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Navigator.pushNamed(context, '/message',
      //     arguments: MessageArguments(message, true));
    });
    FirebaseMessaging.onMessageOpenedAppWhenCallAccept
        .listen((RemoteMessage message) {
      print("FirebaseMessaging.onMessageOpenedAppWhenCallAccept");
      if (message.data['type'] == 'video_call') {


        CallRemoteMessage callRemoteMessage =
            CallRemoteMessage.fromJson(message.data);
        // avoid repeat call
        if(channelName !=callRemoteMessage.callerId || _callProvider.isCalled==false)
          {
            channelName=callRemoteMessage.callerId;
            print("callRemoteMessage " + callRemoteMessage.toString());

            _callProvider.startVideoCall(context:context, channelName:   callRemoteMessage.callerId);
          }


        // Navigator.of(context).pushNamedIfNotCurrent('/call');
      }
    });

    // End callKit
  }

  void _requestPermissionsLocalNotification() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  // callkit IOS

  onCallAccepted(String uuid, String number) async {
    print("[ContactPage onCallAccepted]");
    _callProvider.startVideoCall(context:context, channelName:   number);


  }


  onCallEnded(String uuid)  async{
    print("[ContactPage onCallEnded]");
    await _callProvider.endCall();
  }

  onNewCallShown() {
    print("[ContactPage onNewCallShown]");
  }

  onMuteCall(bool mute, String uuid) {
    print("[ContactPage onMuteCall]");
  }

  // END callkit IOS

  @override
  void dispose() {
    // clear users

    // destroy sdk

    WidgetsBinding.instance?.removeObserver(this);
    // VideoCallManager.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
    } else if (state == AppLifecycleState.resumed) {
      print("didChangeAppLifecycleState resumed");
      // CallKitManager.instance.endAllCall();
    }
  }


  Future<void> onPressCall() async {
    String channelName = "trong_test";
    print("channelName " + channelName);
  _callProvider.startVideoCall(context: context,channelName: channelName,startCall: true);
    // await joinVideoFroIosLock(channelName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Contact",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
            itemCount: 3,
            padding: EdgeInsets.only(top: 10),
            itemBuilder: (BuildContext context, int index) {
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        Column(
                          children: [
                            Text("Name",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            Text("Description",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black)),
                          ],
                        )
                      ],
                    )),
                    IconButton(onPressed: onPressCall, icon: Icon(Icons.call)),
                  ],
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onPressShowNotification,
      ),
    );
  }
  onPressShowNotification() async{
    Set<int> opponentsIds = {};
    opponentsIds.add(1);
    opponentsIds.add(2);
    await ConnectycubeFlutterCallKit.showCallNotification(
        sessionId: "test",
        callType: 1,
        callerId: 1,
        callerName: "test",
        opponentsIds: opponentsIds,
        userInfo: {},
        messageId:"test");
  }
}
