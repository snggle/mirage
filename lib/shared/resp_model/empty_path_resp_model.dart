import 'package:mirage/shared/resp_model/a_resp_model.dart';

class EmptyPathRespModel implements ARespModel {
  String version;
  String githash;

  EmptyPathRespModel({
    required this.version,
    required this.githash,
  });

  @override
  String toPlaintext() {
    String versionValue = '"$version"';
    String githashValue = '"$githash"';
    return '{"version":$versionValue,"githash":$githashValue}\n';
  }
}
