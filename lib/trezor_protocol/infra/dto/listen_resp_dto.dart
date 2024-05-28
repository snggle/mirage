import 'package:mirage/trezor_protocol/infra/dto/a_resp_dto.dart';

class ListenRespDto implements ARespDto {
  String path;
  int vendor;
  int product;
  bool debug;
  String? session;
  String? debugSession;

  ListenRespDto({
    this.path = '1',
    this.vendor = 1,
    this.product = 0,
    this.debug = false,
    this.session,
    this.debugSession,
  });

  @override
  String toPlaintext() {
    String pathValue = '"$path"';
    String vendorValue = '$vendor';
    String productValue = '$product';
    String debugValue = '$debug';
    String sessionValue = session == null ? 'null' : '"$session"';
    String debugSessionValue = debugSession == null ? 'null' : '"$debugSession"';

    return '[{"path":$pathValue,"vendor":$vendorValue,"product":$productValue,"debug":$debugValue,"session":$sessionValue,"debugSession":$debugSessionValue}]\n';
  }
}
