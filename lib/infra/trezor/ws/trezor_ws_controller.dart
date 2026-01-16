import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_ws_communication_notifier.dart';
import 'package:mirage/infra/trezor/ws/dto/req/ws_envelope.dart';
import 'package:mirage/infra/trezor/ws/dto/resp/error_resp.dart';
import 'package:mirage/infra/trezor/ws/dto/resp/frame_call_resp.dart';
import 'package:mirage/infra/trezor/ws/dto/resp/pong_resp.dart';
import 'package:mirage/infra/trezor/ws/dto/resp/popup_handshake_resp.dart';
import 'package:mirage/shared/utils/app_logger.dart';

class TrezorWsController {
  final TrezorWsCommunicationNotifier _trezorWsCommunicationNotifier = globalLocator<TrezorWsCommunicationNotifier>();

  Completer<void>? listenRequestCompleter;
  String? activeSession;

  static const String _connectPath = '/connect-ws';

  Future<void> handleRequest(HttpRequest request) async {
    String path = request.uri.path;

    if (path != _connectPath) {
      await _respondNotFound(request);
      return;
    }

    if (WebSocketTransformer.isUpgradeRequest(request) == false) {
      await _respondNotAllowed(request);
      return;
    }

    await _handleConnectWs(request);
  }

  Future<void> _respondNotAllowed(HttpRequest request) async {
    request.response
      ..statusCode = HttpStatus.methodNotAllowed
      ..write('Method not allowed');
    await request.response.close();
  }

  Future<void> _respondNotFound(HttpRequest request) async {
    request.response
      ..statusCode = HttpStatus.notFound
      ..write('Unknown request');
    await request.response.close();
  }

  Future<void> _handleConnectWs(HttpRequest request) async {
    AppLogger().log(
      message: 'WS upgrade from origin=${request.headers.value('origin')} '
          'protocol=${request.headers.value('sec-websocket-protocol')}',
    );

    try {
      WebSocket ws = await WebSocketTransformer.upgrade(request);

      AppLogger().log(message: 'WS connected');
      ws
        ..pingInterval = const Duration(seconds: 10)
        ..listen(
          (dynamic message) async {
            if (message is String) {
              AppLogger().log(message: 'WS <= $message');
              await _handleWsMessage(message, ws);
            } else if (message is List<int>) {
              AppLogger().log(message: 'WS <= (binary ${message.length} bytes)');
            }
          },
          onDone: () => AppLogger().log(
            message: 'WS closed. code=${ws.closeCode} reason=${ws.closeReason}',
          ),
          onError: (dynamic e) => AppLogger().log(message: 'WS error: $e'),
          cancelOnError: true,
        );
    } catch (e) {
      AppLogger().log(message: 'WS upgrade failed: $e');

      try {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('WebSocket upgrade failed');
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> _handleWsMessage(String message, WebSocket ws) async {
    Map<String, dynamic>? obj = _decodeJsonObject(message);
    if (obj == null) {
      AppLogger().log(message: 'WS <= invalid JSON, ignoring');
      return;
    }

    late WsEnvelope wsEnvelope;
    try {
      wsEnvelope = WsEnvelope.fromJson(obj);
    } catch (e) {
      AppLogger().log(message: 'WS <= invalid envelope: $e');
      return;
    }

    switch (wsEnvelope.type) {
      case 'popup-handshake':
        _handlePopupHandshake(ws, wsEnvelope);
        return;

      case 'ping':
        _handlePing(ws, wsEnvelope);
        return;

      case 'iframe-call':
        await _handleTrezorRequest(ws, wsEnvelope);
        return;

      default:
        _handleError(ws, wsEnvelope.id, 'unknown type');
        return;
    }
  }

  Map<String, dynamic>? _decodeJsonObject(String message) {
    try {
      dynamic decoded = jsonDecode(message);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void _handlePopupHandshake(WebSocket ws, WsEnvelope wsEnvelope) {
    PopupHandshakeResp popupHandshakeResp = PopupHandshakeResp(id: wsEnvelope.id);
    _respond(ws, popupHandshakeResp.toJson(), log: 'WS => handshake for id=${wsEnvelope.id}: $popupHandshakeResp');
  }

  void _handlePing(WebSocket ws, WsEnvelope wsEnvelope) {
    PongResp pongResp = PongResp(id: wsEnvelope.id);
    _respond(ws, pongResp.toJson(), log: 'WS => pong for id=${wsEnvelope.id}: $pongResp');
  }

  Future<void> _handleTrezorRequest(WebSocket ws, WsEnvelope wsEnvelope) async {
    Map<String, dynamic>? payload = wsEnvelope.payload;
    if (payload == null) {
      _handleError(ws, wsEnvelope.id, 'empty payload');
      return;
    }

    String? method = payload['method'] as String?;
    if (method == null || method.isEmpty) {
      _handleError(ws, wsEnvelope.id, 'missing method');
      return;
    }

    try {
      Map<String, Object?> respPayload = await _trezorWsCommunicationNotifier.getResponsePayload(payload);
      FrameCallResp frameCallResp = FrameCallResp(id: wsEnvelope.id, respPayload: respPayload);
      _respond(ws, frameCallResp.toJson(), log: 'WS => resp for id=${wsEnvelope.id}: $frameCallResp');
    } catch (e) {
      _handleError(ws, wsEnvelope.id, e.toString());
    }
  }

  void _handleError(WebSocket ws, String id, String error) {
    ErrorResp errorResp = ErrorResp(error: error, id: id);
    _respond(ws, errorResp.toJson(), log: 'WS => error for id=${id}: $errorResp');
  }

  void _respond(WebSocket ws, Map<String, dynamic> json, {String? log}) {
    String encodedResp = jsonEncode(json);
    ws.add(encodedResp);
    if (log != null) {
      AppLogger().log(message: log);
    }
  }
}
