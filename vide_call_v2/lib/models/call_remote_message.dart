class CallRemoteMessage {
  String type;
  String callerId;
  String callerName;
  String callerIdType;
  bool hasVideo;

  CallRemoteMessage(
      {this.type,
      this.callerId,
      this.callerName,
      this.callerIdType,
      this.hasVideo});

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'caller_id': callerId,
      'caller_name': callerName,
      'caller_id_type': callerIdType,
      'has_video': hasVideo,
    };
  }

  CallRemoteMessage.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        callerId = json['caller_id'],
        callerName = json['caller_name'],
        callerIdType = json['caller_id_type'],
        hasVideo = json['has_video'] == "true" ? true : false;

  @override
  String toString() {
    // TODO: implement toString
    return 'CallRemoteMessage:{ type: ${type.toString()}, caller_id: ${callerId.toString()}, caller_name:$callerName, caller_id_type:$callerIdType}';

  }
}
