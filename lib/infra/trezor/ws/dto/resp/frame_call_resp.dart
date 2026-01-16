import 'package:mirage/infra/trezor/ws/dto/resp/i_ws_resp.dart';

class FrameCallResp implements IWsResp {
  final String id;
  final Map<String, Object?> respPayload;

  const FrameCallResp({
    required this.id,
    required this.respPayload,
  });

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'success': true,
        'payload': respPayload,
        'device': <String, Object>{
          'path': 'b265a417',
          'state': <String, Object>{
            'staticSessionId': 'n3rSLT9Fojbd6FqtmGG6T6y5KveugeyGGf@3D07E6C7214DCA7E8E312709:1',
            'sessionId': 'c59f3853c2b26936866bbc3622a194e169f304af1aa27bc30fc7d2bcdb7c3fe7',
            'deriveCardano': false,
          },
          'instance': 1,
        },
      };
}
