import 'dart:convert';
import 'dart:io';

import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor_http/trezor_http_service.dart';
import 'package:mirage/trezor_protocol/controllers/http_request_type.dart';
import 'package:mirage/trezor_protocol/controllers/trezor_communication_controller.dart';

// ignore_for_file: avoid_print
class TrezorHttpController {
  String? session;
  HttpRequest? requestListen;
  TrezorCommunicationController protobufController = globalLocator<TrezorCommunicationController>();
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
      if (request.uri.pathSegments.isEmpty) {
        trezorHttpService.respondOk(request, requestType);
      } else {
        switch (requestType) {
          case RequestType.enumerate:
            trezorHttpService.respondOk(request, requestType, session: session);
            break;

          case RequestType.listen:
            requestListen = request;
            break;

          case RequestType.acquire:
            session = request.uri.pathSegments[1];
            trezorHttpService.respondOk(request, requestType, session: session);

            if (requestListen != null) {
              trezorHttpService.respondOk(
                  requestListen!, RequestType.listen, session: session);
              requestListen = null;
            }
            break;

          case RequestType.release:
            trezorHttpService.respondOk(request, requestType, session: session);
            session = null;

            if (requestListen != null) {
              trezorHttpService.respondOk(
                  requestListen!, RequestType.listen, session: session);
              requestListen = null;
            }
            break;

          case RequestType.call:
            String inputBuffer = await utf8.decoder.bind(request).join();

            String outputBuffer = await protobufController.handleBuffer(inputBuffer);

            trezorHttpService.respondOk(request, requestType, respBuffer: outputBuffer);
            break;

          default:
            trezorHttpService.respondNotFound(request);
        }
      }
    } catch (e) {
      print('Error handling request: $e, request: $request');
      trezorHttpService.respondInternalError(request);
    }
  }
}
