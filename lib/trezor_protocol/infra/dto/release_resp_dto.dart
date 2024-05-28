import 'package:mirage/trezor_protocol/infra/dto/a_resp_dto.dart';

class ReleaseRespDto implements ARespDto {
  String session;

  ReleaseRespDto({
    required this.session,
  });

  @override
  String toPlaintext() {
    String sessionValue = '"$session"';
    return '{"session":$sessionValue}\n';
  }
}
