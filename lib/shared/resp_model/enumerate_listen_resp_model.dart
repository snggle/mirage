import 'package:mirage/shared/resp_model/a_resp_model.dart';

class EnumerateListenRespModel implements ARespModel {
  String path;
  int vendor;
  int product;
  bool debug;
  String? session;
  String? debugSession;

  EnumerateListenRespModel({
    required this.path,
    required this.vendor,
    required this.product,
    required this.debug,
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
