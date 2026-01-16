import 'package:mirage/infra/trezor/ws/dto/resp/i_ws_resp.dart';

class PongResp implements IWsResp {
  final String id;

  const PongResp({required this.id});

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': 'pong',
        'payload': <String, bool>{'ok': true},
      };
}
