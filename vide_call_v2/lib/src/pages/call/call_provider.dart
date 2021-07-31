import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vide_call_v2/services/call_kit_manager.dart';
import 'package:vide_call_v2/services/safety/change_notifier_safety.dart';
import 'package:vide_call_v2/utils/app_route.dart';
import 'package:vide_call_v2/utils/settings.dart';
import 'package:vide_call_v2/utils/navigator_state_extension.dart';
class CallProvider extends ChangeNotifierSafety {
  RtcEngine _engine;
  List<int> _users = <int>[];
  List<String> _infoStrings = <String>[];

  bool muted = false;
  bool isCalled=false;

  List<int> get users=>_users;
  List<String> get infoStrings=>_infoStrings;
  // void addInfoStrings(String message)
  // {
  //   _infoStrings.add(message);
  //   notifyListeners();
  // }
  @override
  void resetState() {
    // TODO: implement resetState
  }
  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
  Future<void> startVideoCallFromIncomingCall({BuildContext context,String channelName}) async
  {

    await joinChannel(channelName);
    Navigator.of(context).pushReplacementNamed(AppRoute.routeCall);
  }
  Future<void> startVideoCall({BuildContext context,String channelName,bool startCall=false}) async
  {

    isCalled=true;
    await joinChannel(channelName);

    Navigator.of(context).pushNamedIfNotCurrent(AppRoute.routeCall,arguments: startCall);

  }

  Future<void> joinChannel(String chanelName) async {
    if (APP_ID.isEmpty) {
      _infoStrings.add(
        'APP_ID missing, please provide your APP_ID in settings.dart',
      );
      _infoStrings.add('Agora Engine is not starting');
      notifyListeners();
      return;
    }

    // await VideoCallManager.instance.initialize();
     await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    await _initAgoraRtcEngine();

    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);

    await _engine.joinChannel(Token, chanelName, null, 0);

  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    _addAgoraEventHandlers();
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      final info = 'onError: $code';
      _infoStrings= [..._infoStrings, info];

      notifyListeners();
    }, joinChannelSuccess: (channel, uid, elapsed) {
      final info = 'onJoinChannel: $channel, uid: $uid';
      _infoStrings= [..._infoStrings, info];
      notifyListeners();
    }, leaveChannel: (stats) {
      _infoStrings= [..._infoStrings, 'onLeaveChannel'];

      _users.clear();
      notifyListeners();
    }, userJoined: (uid, elapsed) {
      final info = 'userJoined: $uid';
      _infoStrings= [..._infoStrings, info];

      _users.add(uid);
      notifyListeners();
    }, userOffline: (uid, elapsed) {
      final info = 'userOffline: $uid';
      _infoStrings= [..._infoStrings, info];

      _users.remove(uid);
      notifyListeners();
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      final info = 'firstRemoteVideo: $uid ${width}x $height';
      _infoStrings= [..._infoStrings, info];

      notifyListeners();
    }));
  }
  Future<void> endCall() async
  {
    isCalled=false;
    _users.clear();
    _infoStrings.clear();
    CallKitManager.instance.endAllCall();
    // destroy sdk
    await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: false);
    if(_engine!=null)
      {
        _engine.leaveChannel();
        _engine.destroy();
        _engine=null;
      }
  }

}
