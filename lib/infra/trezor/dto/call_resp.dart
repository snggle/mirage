import 'package:mirage/infra/trezor/dto/i_trezor_resp.dart';

class CallResp implements ITrezorResp {
  final String buffer;

  CallResp({required this.buffer});

  @override
  String toPlaintext() {
    return buffer;
  }
}
