import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_call_kit/flutter_call_kit.dart';
import 'package:uuid/uuid.dart';
import 'package:vide_call_v2/models/call_response.dart';

class CallKitManager {
  static CallKitManager get instance => _getInstance();
  static CallKitManager _instance;
  static String TAG = "CallKitManager";

  static CallKitManager _getInstance() {
    if (_instance == null) {
      _instance = CallKitManager._internal();
    }
    return _instance;
  }

  factory CallKitManager() => _getInstance();

  CallKitManager._internal() {
    this._callKeep = FlutterCallkeep();
  }

  Map<String, CallResponse> calls = {};
  FlutterCallkeep _callKeep;

  Function(String uuid, String number) _onCallAccepted;
  Function(String uuid) _onCallEnded;
  Function _onNewCallShown;
  Function(bool mute, String uuid) _onMuteCall;

  init(
      {@required onCallAccepted(String uuid, String number),
      @required onCallEnded(String uuid),
      @required onNewCallShown(),
      @required onMuteCall(bool mute, String uuid)}) {
    this._onCallAccepted = onCallAccepted;
    this._onCallEnded = onCallEnded;
    this._onNewCallShown = onNewCallShown;
    this._onMuteCall = onMuteCall;
    if (Platform.isIOS) {
      _callKeep.on(CallKeepDidDisplayIncomingCall(), _didDisplayIncomingCall);
      _callKeep.on(CallKeepPerformAnswerCallAction(), _answerCall);
      _callKeep.on(
          CallKeepDidActivateAudioSession(), _callKeepDidActivateAudioSession);
      _callKeep.on(CallKeepDidPerformDTMFAction(), _didPerformDTMFAction);
      _callKeep.on(
          CallKeepDidReceiveStartCallAction(), _didReceiveStartCallAction);
      _callKeep.on(CallKeepDidToggleHoldAction(), _didToggleHoldCallAction);
      _callKeep.on(CallKeepDidPerformSetMutedCallAction(),
          _didPerformSetMutedCallAction);
      _callKeep.on(CallKeepPerformEndCallAction(), _endCall);
      _callKeep.on(CallKeepPushKitToken(), _onPushKitToken);

      _callKeep.setup(<String, dynamic>{
        'ios': {
          'appName': 'CallKeepDemo',
        },
        'android': {
          'alertTitle': 'Permissions required',
          'alertDescription':
              'This application needs to access your phone accounts',
          'cancelButton': 'Cancel',
          'okButton': 'ok',
        },
      });
    }
  }

  void _didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) {
    if (Platform.isIOS) {
      String callUUID = event.callUUID;
      var number = event.handle;
      print('[xxxxxxxxxxx displayIncomingCall] ${callUUID} number: $number');
      calls[callUUID] = CallResponse(number);
      _onNewCallShown();
    }
  }

  Future<void> _answerCall(CallKeepPerformAnswerCallAction event) async {
    if (Platform.isIOS) {
      final String callUUID = event.callUUID;
      final String number = calls[callUUID].number;
      print('[xxxxxxxxxxx answerCall] $callUUID, number: $number');
      _onCallAccepted(callUUID, number);
      //
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => CallPage(
      //       channelName: number,
      //       role: ClientRole.Broadcaster,
      //     ),
      //   ),
      // );

      // await _initAgoraRtcEngine();
      // await _engine.joinChannel(Token, number, null, 0);

      _callKeep.startCall(event.callUUID, number, number);
      // Timer(const Duration(seconds: 1), () {
      //   print('[xxxxxxxxxxx setCurrentCallActive] $callUUID, number: $number');
      //   _callKeep.setCurrentCallActive(callUUID);
      // });
    }
  }

  void _callKeepDidActivateAudioSession(CallKeepDidActivateAudioSession event)  {
    print('[xxxxxxxxx CallKeepDidActivateAudioSession] ');
  }

  Future<void> _endCall(CallKeepPerformEndCallAction event) async {
    if (Platform.isIOS) {
      print('xxxxxxxxxxx endCall: ${event.callUUID}');

      removeCall(event.callUUID);
      _onCallEnded(event.callUUID);
      // await _engine.leaveChannel();
    }
  }

  void removeCall(String callUUID) {
    calls.remove(callUUID);
  }

  Future<void> _didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
    print('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
  }

  Future<void> _didReceiveStartCallAction(
      CallKeepDidReceiveStartCallAction event) async {
    if (event.handle == null) {
      // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
      return;
    }
    final String callUUID = event.callUUID ?? _newUUID();
    calls[callUUID] = CallResponse(event.handle);
    print(
        '[xxxxxxxxxxxx didReceiveStartCallAction] $callUUID, number: ${event.handle}');

    _callKeep.startCall(callUUID, event.handle, event.handle);

    Timer(const Duration(seconds: 1), () {
      print(
          '[xxxxxxxxxxx setCurrentCallActive] $callUUID, number: ${event.handle}');
      _callKeep.setCurrentCallActive(callUUID);
    });
  }

  Future<void> _didToggleHoldCallAction(
      CallKeepDidToggleHoldAction event) async {
    final String number = calls[event.callUUID].number;
    print(
        '[xxxxxxxxxxx didToggleHoldCallAction] ${event.callUUID}, number: $number (${event.hold})');

    _setCallHeld(event.callUUID, event.hold);
  }

  void _onPushKitToken(CallKeepPushKitToken event) {
    print('[onPushKitToken] token => ${event.token}');
  }

  void _setCallHeld(String callUUID, bool held) {
    calls[callUUID].held = held;
  }

  void _setCallMuted(String callUUID, bool muted) {
    calls[callUUID].muted = muted;
  }

  Future<void> endAllCall() async {

    if (Platform.isIOS) {
      await _callKeep.endAllCalls();
      calls.clear();
    }



  }

  String _newUUID() => Uuid().v4();

  Future<void> _didPerformSetMutedCallAction(
      CallKeepDidPerformSetMutedCallAction event) async {
    final String number = calls[event.callUUID].number;
    print(
        '[xxxxxxxxxxx didPerformSetMutedCallAction] ${event.callUUID}, number: $number (${event.muted})');

    _setCallMuted(event.callUUID, event.muted);
  }
}
