import 'package:mirage/infra/trezor/ws/dto/resp/i_ws_resp.dart';

class PopupHandshakeResp implements IWsResp {
  final String id;

  const PopupHandshakeResp({required this.id});

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': 'popup-handshake',
        'payload': <String, bool>{'ok': true},
      };
}
