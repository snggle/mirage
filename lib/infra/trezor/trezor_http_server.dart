import 'dart:async';
import 'dart:io';

import 'package:mirage/infra/trezor/trezor_http_controller.dart';
import 'package:mirage/shared/utils/app_logger.dart';

class TrezorHttpServer {
  final TrezorHttpController _trezorHttpController = TrezorHttpController();
  late HttpServer _server;

  Future<void> start() async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 21325);
      AppLogger().log(message: 'Running HTTP server on localhost:${_server.port}');

      _server.listen(_trezorHttpController.handleRequest);
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 48 || e.osError?.errorCode == 98) {
        AppLogger().log(message: 'Port 21325 is already in use. Please close the application using this port or try "sudo fuser -k 21325/tcp".');
      } else {
        AppLogger().log(message: 'Failed to bind the HTTP server: $e');
      }
    } catch (e) {
      AppLogger().log(message: 'An unexpected error occurred: $e');
    }
  }

  Future<void> dispose() async {
    await _server.close(force: true);
  }
}