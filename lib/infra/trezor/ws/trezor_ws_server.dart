import 'dart:io';

import 'package:mirage/infra/trezor/ws/trezor_ws_controller.dart';
import 'package:mirage/shared/utils/app_logger.dart';

class TrezorWsServer {
  final TrezorWsController _trezorWsController = TrezorWsController();
  late final HttpServer _server;


  Future<void> start() async {
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 21335);
      AppLogger().log(message: 'Running WS server on ws://127.0.0.1:${_server.port}/connect-ws');


      _server.listen(_trezorWsController.handleRequest);
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 48 || e.osError?.errorCode == 98) {
        AppLogger().log(
          message:
          'Port 21335 is already in use. Close the app using this port or try "sudo fuser -k 21335/tcp".',
        );
        throw Exception('Port already in use');
      } else {
        AppLogger().log(message: 'Failed to bind the WS server: $e');
        throw Exception('Failed to bind the WS server');
      }
    } catch (e) {
      AppLogger().log(message: 'An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> dispose() async {
    await _server.close(force: true);
  }
}