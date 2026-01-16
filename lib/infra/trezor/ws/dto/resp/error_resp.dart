import 'package:mirage/infra/trezor/ws/dto/resp/i_ws_resp.dart';

class ErrorResp implements IWsResp {
  final String id;
  final String error;

  const ErrorResp({
    required this.id,
    required this.error,
  });

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'success': false,
        'payload': <String, String>{'error': error},
      };
}
