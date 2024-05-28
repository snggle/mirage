import 'package:mirage/trezor_protocol/infra/dto/a_resp_dto.dart';

class CallRespDto implements ARespDto {
  String buffer;

  CallRespDto({required this.buffer});

  @override
  String toPlaintext() {
    return buffer;
  }
}
