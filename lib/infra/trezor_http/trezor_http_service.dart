import 'dart:io';

import 'package:mirage/infra/trezor_http/trezor_http_repository.dart';
import 'package:mirage/shared/resp_model/a_resp_model.dart';
import 'package:mirage/shared/resp_model/acquire_release_resp_model.dart';
import 'package:mirage/shared/resp_model/call_resp_model.dart';
import 'package:mirage/shared/resp_model/empty_path_resp_model.dart';
import 'package:mirage/shared/resp_model/enumerate_listen_resp_model.dart';

abstract class _ITrezorHttpService {
  void respondOk(HttpRequest request, String? firstPathSegment, {String? session, String? respBuffer});

  void respondNotAllowed(HttpRequest request);

  void respondNotFound(HttpRequest request);

  void respondInternalError(HttpRequest request);
}

class TrezorHttpService implements _ITrezorHttpService {
  TrezorHttpRepository trezorHttpRepository = TrezorHttpRepository();
  late ARespModel response;

  @override
  void respondOk(HttpRequest request, String? respType, {String? session, String? respBuffer}) {
    ARespModel? respModel;
    switch (respType) {
      case 'empty':
        respModel = EmptyPathRespModel(version: '2.0.34', githash: 'e83287a');
        break;
      case 'enumerate':
      case 'listen':
        respModel = EnumerateListenRespModel(path: '1', vendor: 1, product: 0, debug: false, session: session);
        break;
      case 'acquire':
      case 'release':
        respModel = AcquireReleaseRespModel(session: session);
        break;
      case 'call':
        respModel = CallRespModel(buffer: respBuffer);
    }
    trezorHttpRepository.respondOk(request, respModel);
  }

  @override
  void respondInternalError(HttpRequest request) {
    trezorHttpRepository.respondInternalError(request);
  }

  @override
  void respondNotAllowed(HttpRequest request) {
    trezorHttpRepository.respondNotAllowed(request);
  }

  @override
  void respondNotFound(HttpRequest request) {
    trezorHttpRepository.respondNotFound(request);
  }
}
