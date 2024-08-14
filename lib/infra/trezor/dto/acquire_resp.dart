import 'dart:convert';

import 'package:mirage/infra/trezor/dto/i_trezor_resp.dart';

class AcquireResp implements ITrezorResp {
  final String session;

  AcquireResp({
    required this.session,
  });

  @override
  String toPlaintext() {
    Map<String, dynamic> respData = <String, dynamic>{
      'session': session,
    };
    return jsonEncode(respData);
  }
}
