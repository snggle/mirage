import 'package:mirage/trezor_protocol/infra/dto/a_resp_dto.dart';

class AcquireRespDto implements ARespDto {
  String session;

  AcquireRespDto({
    required this.session,
  });

  @override
  String toPlaintext() {
    String sessionValue = '"$session"';
    return '{"session":$sessionValue}\n';
  }
}
