import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vide_call_v2/utils/settings.dart';

class VideoCallManager {
  static VideoCallManager get instance => _getInstance();
  static VideoCallManager _instance;
  static String TAG = "CallKitManager";

  static VideoCallManager _getInstance() {
    if (_instance == null) {
      _instance = VideoCallManager._internal();
    }
    return _instance;
  }

  factory VideoCallManager() => _getInstance();

  RtcEngine get engine => _engine;

  VideoCallManager._internal() {
    // _initAgoraRtcEngine();
  }

  Future<void> initialize() async {
    await _initAgoraRtcEngine();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);

    print("_engine "+_engine.toString());
  }

  Future<void> dispose() async {
    _engine.leaveChannel();
    _engine.destroy();
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  Future<void> joinVideoCall(String channelName) async {
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    await initialize();
    await _engine.joinChannel(Token, channelName, null, 0);
  }

  RtcEngine _engine;
}
