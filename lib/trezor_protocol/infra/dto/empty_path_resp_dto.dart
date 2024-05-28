import 'package:mirage/trezor_protocol/infra/dto/a_resp_dto.dart';

class EmptyPathRespDto implements ARespDto {
  String version;
  String githash;

  EmptyPathRespDto({
    this.version = '2.0.34',
    this.githash = 'e83287a',
  });

  @override
  String toPlaintext() {
    String versionValue = '"$version"';
    String githashValue = '"$githash"';
    return '{"version":$versionValue,"githash":$githashValue}\n';
  }
}
