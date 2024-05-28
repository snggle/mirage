import 'dart:convert';
import 'dart:io';

import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor_http/trezor_http_service.dart';
import 'package:mirage/shared/http_request_type.dart';
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mirage/trezor_protocol/controllers/trezor_communication_controller.dart';

class TrezorHttpController {
  String? session;
  HttpRequest? requestInProcess;
  TrezorCommunicationController trezorCommunicationController = globalLocator<TrezorCommunicationController>();
  TrezorHttpService trezorHttpService = TrezorHttpService();

  void handleRequest(HttpRequest request) {
    if (request.method == 'POST') {
      handlePost(request);
    } else {
      trezorHttpService.respondNotAllowed(request);
    }
  }

  Future<void> handlePost(HttpRequest request) async {
    String requestTypeString = request.uri.pathSegments.isEmpty ? 'empty' : request.uri.pathSegments.first;
    RequestType requestType = requestTypeString == 'empty' ? RequestType.empty : RequestType.getRequestTypeFromString(requestTypeString);

    try {
      switch (requestType) {
        case RequestType.empty:
          trezorHttpService.respondOk(request, requestType);
          break;

        case RequestType.enumerate:
          trezorHttpService.respondOk(request, requestType, session: session);
          break;

        case RequestType.listen:
          requestInProcess = request;
          break;

        case RequestType.acquire:
          session = _assignSession(request.uri.pathSegments[2]);
          trezorHttpService.respondOk(request, requestType, session: session);
          break;

        case RequestType.release:
          trezorHttpService.respondOk(request, requestType, session: session);
          session = null;
          break;

        case RequestType.call:
          trezorHttpService.respondOk(request, requestType, respBuffer: await _getRespBuffer(request));
          break;

        default:
          trezorHttpService.respondNotFound(request);
      }

      bool sessionInitializedBool = requestType == RequestType.acquire;
      bool sessionEndBool = requestType == RequestType.release;
      if (sessionInitializedBool || sessionEndBool) {
        trezorHttpService.respondOk(requestInProcess!, RequestType.listen, session: session);
        requestInProcess = null;
      }
    } catch (e) {
      AppLogger().log(message: 'Error handling request: $e');
      trezorHttpService.respondInternalError(request);
    }
  }

  String _assignSession(String previousSession) {
    if (previousSession == 'null') {
      return '1';
    } else {
      return (int.parse(previousSession) + 1).toString();
    }
  }

  Future<String> _getRespBuffer(HttpRequest request) async {
    String inputBuffer = await utf8.decoder.bind(request).join();
    String outputBuffer = await trezorCommunicationController.handleBuffer(inputBuffer);
    return outputBuffer;
  }
}
