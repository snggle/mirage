class WsEnvelope {
  final String id;
  final String type;
  final Map<String, dynamic>? payload;

  WsEnvelope({
    required this.id,
    required this.type,
    this.payload,
  });

  factory WsEnvelope.fromJson(Map<String, dynamic> json) {
    dynamic id = json['id'];
    dynamic type = json['type'];
    if (id is String == false || type is String == false) {
      throw const FormatException('Invalid WS envelope: id/type missing');
    }

    dynamic payload = json['payload'];
    return WsEnvelope(
      id: id as String,
      type: type as String,
      payload: payload is Map ? Map<String, dynamic>.from(payload) : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type,
        if (payload != null) 'payload': payload,
      };
}
