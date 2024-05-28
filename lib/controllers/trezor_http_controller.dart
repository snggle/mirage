import 'dart:convert';
import 'dart:io';

import 'package:mirage/config/locator.dart';
import 'package:mirage/controllers/protobuf_controller.dart';
import 'package:mirage/infra/trezor_http/trezor_http_service.dart';
import 'package:mirage/protobuf/msg_serializer/msg_serializer.dart';
import 'package:protobuf/protobuf.dart' as $pb;


// ignore_for_file: avoid_print
class TrezorHttpController {
  String? session;
  HttpRequest? requestListen;
  ProtobufController protobufController = globalLocator<ProtobufController>();
  TrezorHttpService trezorHttpService = TrezorHttpService();

  void handleRequest(HttpRequest request) {
    if (request.method == 'POST') {
      handlePost(request);
    } else {
      trezorHttpService.respondNotAllowed(request);
    }
  }

  Future<void> handlePost(HttpRequest request) async {
    String respType = request.uri.pathSegments.isEmpty ? 'empty' : request.uri.pathSegments.first;

    try {
      if (request.uri.pathSegments.isEmpty) {
        trezorHttpService.respondOk(request, respType);
      } else {
        switch (respType) {
          case 'enumerate':
            trezorHttpService.respondOk(request, respType, session: session);
            break;

          case 'listen':
            requestListen = request;
            break;

          case 'acquire':
            session = request.uri.pathSegments[1];
            trezorHttpService.respondOk(request, respType, session: session);

            if (requestListen != null) {
              trezorHttpService.respondOk(
                  requestListen!, 'listen', session: session);
              requestListen = null;
            }
            break;

          case 'release':
            trezorHttpService.respondOk(request, respType, session: session);
            session = null;

            if (requestListen != null) {
              trezorHttpService.respondOk(
                  requestListen!, 'listen', session: session);
              requestListen = null;
            }
            break;

          case 'call':
            String inputBuffer = await utf8.decoder.bind(request).join();

            $pb.GeneratedMessage inputMsg = MsgSerializer.deserializeBuffer(inputBuffer);
            $pb.GeneratedMessage? outputMsg = await protobufController.getResponse(inputMsg);
            String? preparedResponse = outputMsg == null ? null : MsgSerializer.serializeMsg(outputMsg);

            trezorHttpService.respondOk(request, respType, respBuffer: preparedResponse);
            break;

          default:
            trezorHttpService.respondNotFound(request);
        }
      }
    } catch (e) {
      print('Error handling request: $e');
      trezorHttpService.respondInternalError(request);
    }
  }
}
