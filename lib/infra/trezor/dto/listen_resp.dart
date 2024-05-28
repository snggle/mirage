import 'dart:convert';

import 'package:mirage/infra/trezor/dto/i_trezor_resp.dart';

class ListenResp implements ITrezorResp {
  final String path;
  final int vendor;
  final int product;
  final bool debug;
  final String? session;
  final String? debugSession;

  ListenResp({
    this.path = '1',
    this.vendor = 1,
    this.product = 0,
    this.debug = false,
    this.session,
    this.debugSession,
  });

  @override
  String toPlaintext() {
    Map<String, dynamic> respData = <String, dynamic>{
      'path': path,
      'vendor': vendor,
      'product': product,
      'debug': debug,
      'session': session,
      'debugSession': debugSession,
    };
    return jsonEncode(<Map<String, dynamic>>[respData]);  }
}
