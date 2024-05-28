import 'dart:convert';

import 'package:mirage/infra/trezor/dto/i_trezor_resp.dart';

class EmptyPathResp implements ITrezorResp {
  final String version;
  final String githash;

  EmptyPathResp({
    this.version = '2.0.34',
    this.githash = 'e83287a',
  });

  @override
  String toPlaintext() {
    Map<String, dynamic> respData = <String, dynamic>{
      'version': version,
      'githash': githash,
    };
    return jsonEncode(respData);
  }
}
