import 'dart:io';

import 'package:mirage/infra/trezor_http/trezor_http_repository.dart';
import 'package:mirage/shared/http_request_type.dart';
import 'package:mirage/trezor_protocol/infra/dto/a_resp_dto.dart';
import 'package:mirage/trezor_protocol/infra/dto/acquire_resp_dto.dart';
import 'package:mirage/trezor_protocol/infra/dto/call_resp_dto.dart';

import 'package:mirage/trezor_protocol/infra/dto/empty_path_resp_dto.dart';
import 'package:mirage/trezor_protocol/infra/dto/enumerate_resp_dto.dart';
import 'package:mirage/trezor_protocol/infra/dto/listen_resp_dto.dart';
import 'package:mirage/trezor_protocol/infra/dto/release_resp_dto.dart';

abstract class _ITrezorHttpService {
  void respondOk(HttpRequest request, RequestType? reqType, {String? session, String? respBuffer});

  void respondNotAllowed(HttpRequest request);

  void respondNotFound(HttpRequest request);

  void respondInternalError(HttpRequest request);
}

class TrezorHttpService implements _ITrezorHttpService {
  TrezorHttpRepository trezorHttpRepository = TrezorHttpRepository();
  late ARespDto response;

  @override
  void respondOk(HttpRequest request, RequestType? requestType, {String? session, String? respBuffer}) {
    ARespDto? respModel;
    switch (requestType) {
      case RequestType.empty:
        respModel = EmptyPathRespDto();
        break;
      case RequestType.enumerate:
        respModel = EnumerateRespDto(session: session);
        break;
      case RequestType.listen:
        respModel = ListenRespDto(session: session);
        break;
      case RequestType.acquire:
        respModel = AcquireRespDto(session: session!);
        break;
      case RequestType.release:
        respModel = ReleaseRespDto(session: session!);
        break;
      case RequestType.call:
        respModel = CallRespDto(buffer: respBuffer!);
      default:
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
