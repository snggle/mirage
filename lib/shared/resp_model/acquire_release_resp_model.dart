import 'package:mirage/shared/resp_model/a_resp_model.dart';

class AcquireReleaseRespModel implements ARespModel {
  String? session;

  AcquireReleaseRespModel({
    this.session,
  });

  @override
  String toPlaintext() {
    String sessionValue = session == null ? 'null' : '"$session"';
    return '{"session":$sessionValue}\n';
  }
}
