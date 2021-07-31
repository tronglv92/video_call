import 'dart:io';

import 'package:flutter/material.dart';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';

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

  CallKitManager._internal() {}

  Function(String uuid) onCallAccepted;
  Function(String uuid) onCallEnded;
  Function(String error, String uuid, String handle, String localizedCallerName,
      bool fromPushKit) onNewCallShown;
  Function(bool mute, String uuid) onMuteCall;

  init({
    @required onCallAccepted(uuid),
    @required onCallEnded(uuid),

  }) {
    this.onCallAccepted = onCallAccepted;
    this.onCallEnded = onCallEnded;


    ConnectycubeFlutterCallKit.instance.init(
      onCallAccepted: _onCallAccepted,
      onCallRejected: _onCallRejected,
    );
  }

  // call when opponent(s) end call
  Future<void> reportEndCallWithUUID(String uuid) async {
    if (Platform.isAndroid) {
      ConnectycubeFlutterCallKit.reportCallEnded(sessionId: uuid);
      ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: false);
    }
  }

  Future<void> endCall(String uuid) async {
    if (Platform.isAndroid) {
      ConnectycubeFlutterCallKit.reportCallEnded(sessionId: uuid);
      ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: false);
    }
  }

  Future<void> rejectCall(String uuid) async {
    if (Platform.isAndroid) {
      ConnectycubeFlutterCallKit.reportCallEnded(sessionId: uuid);
      ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: false);
    }
  }

  /// Event Listener Callbacks for 'flutter_call_kit'
  Future<void> _performAnswerCallAction(String uuid) async {
    // Called when the user answers an incoming call
    onCallAccepted.call(uuid);
  }

  Future<void> _performEndCallAction(String uuid) async {
    onCallEnded.call(uuid);
  }

  Future<void> _didDisplayIncomingCall(String error, String uuid, String handle,
      String localizedCallerName, bool fromPushKit) async {
    onNewCallShown.call(error, uuid, handle, localizedCallerName, fromPushKit);
  }

  Future<void> _didPerformSetMutedCallAction(bool mute, String uuid) async {
    onMuteCall.call(mute, uuid);
  }

  /// Event Listener Callbacks for 'connectycube_flutter_call_kit'
  Future<void> _onCallAccepted(
      String sessionId,
      int callType,
      int callerId,
      String callerName,
      Set<int> opponentsIds,
      Map<String, String> userInfo) async {
    onCallAccepted.call(sessionId);
  }

  Future<void> _onCallRejected(
      String sessionId,
      int callType,
      int callerId,
      String callerName,
      Set<int> opponentsIds,
      Map<String, String> userInfo) async {
    onCallEnded.call(sessionId);
  }
}
