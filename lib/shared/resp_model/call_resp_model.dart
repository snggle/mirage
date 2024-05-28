import 'package:mirage/shared/resp_model/a_resp_model.dart';

class CallRespModel implements ARespModel {
  String? buffer;

  CallRespModel({this.buffer});

  @override
  String toPlaintext() {
    return buffer ?? '';
  }
}
