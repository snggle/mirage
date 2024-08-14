import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/dto/acquire_resp.dart';
import 'package:mirage/infra/trezor/dto/call_resp.dart';
import 'package:mirage/infra/trezor/dto/empty_path_resp.dart';
import 'package:mirage/infra/trezor/dto/enumerate_resp.dart';
import 'package:mirage/infra/trezor/dto/i_trezor_resp.dart';
import 'package:mirage/infra/trezor/dto/listen_resp.dart';
import 'package:mirage/infra/trezor/dto/release_resp.dart';
import 'package:mirage/infra/trezor/trezor_communication_notifier.dart';
import 'package:mirage/shared/utils/app_logger.dart';

class TrezorHttpController {
  final TrezorCommunicationNotifier _trezorCommunicationNotifier = globalLocator<TrezorCommunicationNotifier>();
  Completer<void>? listenRequestCompleter;
  String? activeSession;

  Future<void> handleRequest(HttpRequest request) async {
    if (request.method != 'POST') {
      await _respondNotAllowed(request);
      return;
    }

    List<String> requestPathSegments = request.uri.toString().replaceFirst('/', '').split('/');
    String path = '/${requestPathSegments.firstOrNull ?? ''}';
    List<String> pathSegments = requestPathSegments.sublist(1);

    await _handlePostQuery(request, path, pathSegments);
  }

  Future<void> _handlePostQuery(HttpRequest request, String path, List<String> pathSegments) async {
    return switch (path) {
      '/' => _handleInitialRequest(request),
      '/enumerate' => _handleEnumerateRequest(request),
      '/listen' => _handleListenRequest(request),
      '/acquire' => _handleAcquireRequest(request, pathSegments[1]),
      '/call' => _handleCallRequest(request),
      '/release' => _handleReleaseRequest(request),
      (_) => _respondNotFound(request),
    };
  }

  /// Path: POST /
  /// Returns current version of the Trezor Bridge.
  Future<void> _handleInitialRequest(HttpRequest request) async {
    try {
      ITrezorResp response = EmptyPathResp();
      await _respondOk(request, response.toPlaintext());
    } catch (_) {
      await _respondInternalError(request);
    }
  }

  /// Path: POST /enumerate
  /// Lists devices. "path" uniquely defines device between more connected devices.
  /// Two different devices (or device connected and disconnected) will return different paths.
  /// If session is null, nobody else is using the device; if it's string, it identifies who is using it.
  Future<void> _handleEnumerateRequest(HttpRequest request) async {
    try {
      ITrezorResp response = EnumerateResp(session: activeSession);
      await _respondOk(request, response.toPlaintext());
    } catch (_) {
      await _respondInternalError(request);
    }
  }

  /// Path: POST /listen
  /// Listen to changes and returns either on change or after 30 second timeout.
  /// Compares change from previous that is sent as a parameter. "Change" is both connecting/disconnecting and session change.
  Future<void> _handleListenRequest(HttpRequest request) async {
    if (listenRequestCompleter?.isCompleted == false) {
      listenRequestCompleter?.complete();
    }
    listenRequestCompleter = Completer<void>();
    unawaited(() async {
      try {
        await listenRequestCompleter!.future;
        ITrezorResp response = ListenResp(session: activeSession);

        await _respondOk(request, response.toPlaintext());
      } catch (_) {
        await _respondInternalError(request);
      }
    }());
  }

  /// Path: POST /acquire/{{path}}/{{previous}}
  /// Acquires the device at PATH. By "acquiring" the device, you are claiming the device for yourself.
  /// Before acquiring, checks that the current session is PREVIOUS.
  /// If two applications call acquire on a newly connected device at the same time, only one of them succeed.
  Future<void> _handleAcquireRequest(HttpRequest request, String previous) async {
    try {
      activeSession = _assignSession(previous);
      ITrezorResp response = AcquireResp(session: activeSession!);
      await _respondOk(request, response.toPlaintext());

      listenRequestCompleter?.complete();
    } catch (_) {
      await _respondInternalError(request);
    }
  }

  /// Path: POST /call/{{session}}
  /// Both input and output are hexadecimal, encoded in protobuf.
  Future<void> _handleCallRequest(HttpRequest request) async {
    try {
      String payload = await utf8.decoder.bind(request).join();
      String responseBuffer = await _trezorCommunicationNotifier.getResponseBuffer(payload);
      ITrezorResp response = CallResp(buffer: responseBuffer);
      await _respondOk(request, response.toPlaintext());
    } catch (_) {
      await _respondInternalError(request);
    }
  }

  /// Path: POST /release/{{session}}
  /// Releases the device with the given session.
  /// By "releasing" the device, you claim that you don't want to use the device anymore.
  Future<void> _handleReleaseRequest(HttpRequest request) async {
    try {
      ITrezorResp response = ReleaseResp(session: activeSession!);
      activeSession = null;
      await _respondOk(request, response.toPlaintext());

      listenRequestCompleter?.complete();
    } catch (_) {
      await _respondInternalError(request);
    }
  }

  String _assignSession(String previousSession) {
    if (previousSession == 'null') {
      return '1';
    } else {
      return (int.parse(previousSession) + 1).toString();
    }
  }

  Future<void> _respondOk(HttpRequest request, String? response) async {
    try {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.set('Access-Control-Allow-Origin', 'https://connect.trezor.io')
        ..headers.contentType = ContentType.text
        ..write(response);
      await request.response.close();
    } catch (e) {
      AppLogger().log(message: 'Failed to respond to the request: $e');
    }
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

  Future<void> _respondInternalError(HttpRequest request) async {
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write('Internal Server Error');
    await request.response.close();
  }
}
