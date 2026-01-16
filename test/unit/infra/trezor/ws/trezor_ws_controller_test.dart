import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/ws/dto/req/ws_envelope.dart';
import 'package:mirage/infra/trezor/ws/dto/resp/error_resp.dart';
import 'package:mirage/infra/trezor/ws/dto/resp/pong_resp.dart';
import 'package:mirage/infra/trezor/ws/dto/resp/popup_handshake_resp.dart';
import 'package:mirage/infra/trezor/ws/trezor_ws_server.dart';

void main() async {
  const String actualServerUri = 'http://127.0.0.1:21335';
  const String actualWsUri = 'ws://127.0.0.1:21335/connect-ws';

  final HttpClient actualHttpClient = HttpClient();
  late TrezorWsServer trezorWsServer;

  setUpAll(() async {
    await initLocator();
    trezorWsServer = TrezorWsServer();
    await trezorWsServer.start();
  });

  group('Tests of status code responses for different WS request shapes', () {
    test('Should [return statusCode = 404] for request to unknown path', () async {
      // Arrange
      HttpClientRequest actualRequest = await actualHttpClient.getUrl(
        Uri.parse('$actualServerUri/unknown'),
      );

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 404;
      expect(actualStatusCode, expectedStatusCode);
    });

    test('Should [return statusCode = 405] for request to /connect-ws without WS upgrade', () async {
      // Arrange
      HttpClientRequest actualRequest = await actualHttpClient.getUrl(
        Uri.parse('$actualServerUri/connect-ws'),
      );

      // Act
      HttpClientResponse actualResponse = await actualRequest.close();
      int actualStatusCode = actualResponse.statusCode;

      // Assert
      int expectedStatusCode = 405;
      expect(actualStatusCode, expectedStatusCode);
    });
  });

  group('Should test the WS server process', () {
    group('Tests of /connect-ws endpoint', () {
      test('Should [return PopupHandshakeResp] for WS message type=popup-handshake', () async {
        // Arrange
        WebSocket ws = await WebSocket.connect(actualWsUri);

        // Act
        WsEnvelope actualWsEnvelope = WsEnvelope(id: '1', type: 'popup-handshake', payload: null);
        ws.add(jsonEncode(actualWsEnvelope.toJson()));

        String actualResponseRaw = await _readNextTextFrame(ws);
        Map<String, dynamic> actualResponseJson = jsonDecode(actualResponseRaw) as Map<String, dynamic>;

        // Assert
        PopupHandshakeResp expectedPopupHanshakeResp = const PopupHandshakeResp(id: '1');
        Map<String, dynamic> expectedResponseJson = expectedPopupHanshakeResp.toJson();
        expect(actualResponseJson, expectedResponseJson);
        await ws.close();
      });

      test('Should [return PongResp] for WS message type=ping', () async {
        // Arrange
        WebSocket ws = await WebSocket.connect(actualWsUri);

        // Act
        WsEnvelope actualWsEnvelope = WsEnvelope(id: '2', type: 'ping', payload: null);
        ws.add(jsonEncode(actualWsEnvelope.toJson()));

        String actualResponseRaw = await _readNextTextFrame(ws);
        Map<String, dynamic> actualResponseJson = jsonDecode(actualResponseRaw) as Map<String, dynamic>;

        // Assert
        PongResp expectedPongResp = const PongResp(id: '2');
        Map<String, dynamic> expectedResponseJson = expectedPongResp.toJson();

        expect(actualResponseJson, expectedResponseJson);
        await ws.close();
      });

      group('Tests of iframe-call validation', () {
        test('Should [return ErrorResp] for iframe-call with empty payload', () async {
          // Arrange
          WebSocket ws = await WebSocket.connect(actualWsUri);

          // Act
          WsEnvelope actualWsEnvelope = WsEnvelope(id: '3', type: 'iframe-call', payload: null);
          ws.add(jsonEncode(actualWsEnvelope.toJson()));

          String actualResponseRaw = await _readNextTextFrame(ws);
          Map<String, dynamic> actualResponseJson = jsonDecode(actualResponseRaw) as Map<String, dynamic>;

          // Assert
          ErrorResp expectedErrorResp = const ErrorResp(id: '3', error: 'empty payload');
          Map<String, dynamic> expectedResponseJson = expectedErrorResp.toJson();

          expect(actualResponseJson, expectedResponseJson);
          await ws.close();
        });

        test('Should [return ErrorResp] for iframe-call missing method', () async {
          // Arrange
          WebSocket ws = await WebSocket.connect(actualWsUri);

          // Act
          WsEnvelope actualWsEnvelope = WsEnvelope(
            id: '4',
            type: 'iframe-call',
            payload: <String, String>{
              'foo': 'bar',
            },
          );
          ws.add(jsonEncode(actualWsEnvelope.toJson()));

          String actualResponseRaw = await _readNextTextFrame(ws);
          Map<String, dynamic> actualResponseJson = jsonDecode(actualResponseRaw) as Map<String, dynamic>;

          // Assert
          ErrorResp expectedErrorResp = const ErrorResp(id: '4', error: 'missing method');
          Map<String, dynamic> expectedResponseJson = expectedErrorResp.toJson();

          expect(actualResponseJson, expectedResponseJson);
          await ws.close();
        });
      });

      group('Tests of invalid/unknown message types', () {
        test('Should [return ErrorResp] for unknown type', () async {
          // Arrange
          WebSocket ws = await WebSocket.connect(actualWsUri);

          // Act
          WsEnvelope actualWsEnvelope = WsEnvelope(
            id: '5',
            type: 'unknown-type',
            payload: <String, String>{
              'foo': 'bar',
            },
          );
          ws.add(jsonEncode(actualWsEnvelope.toJson()));

          String actualResponseRaw = await _readNextTextFrame(ws);
          Map<String, dynamic> actualResponseJson = jsonDecode(actualResponseRaw) as Map<String, dynamic>;

          // Assert
          ErrorResp expectedErrorResp = const ErrorResp(id: '5', error: 'unknown type');
          Map<String, dynamic> expectedResponseJson = expectedErrorResp.toJson();

          expect(actualResponseJson, expectedResponseJson);
          await ws.close();
        });

        test('Should [ignore invalid JSON] (no response)', () async {
          // Arrange
          WebSocket ws = await WebSocket.connect(actualWsUri);

          // Act
          ws.add('this is not json');

          // Assert
          await expectLater(
            _readNextTextFrame(ws).timeout(const Duration(milliseconds: 300)),
            throwsA(isA<TimeoutException>()),
          );

          await ws.close();
        });
      });
    });
  });

  tearDownAll(() async {
    await trezorWsServer.dispose();
    actualHttpClient.close(force: true);
  });
}

Future<String> _readNextTextFrame(WebSocket ws) async {
  final dynamic msg = await ws.first;
  if (msg is String) {
    return msg;
  }
  throw StateError('Expected WS text frame but got: ${msg.runtimeType}');
}
