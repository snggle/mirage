import 'dart:io';

import 'package:mirage/config/locator.dart';
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mirage/trezor_protocol/controllers/trezor_http_controller.dart';

Future<void> main() async {
  await initLocator();

  try {
    HttpServer server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      21325,
    );

    AppLogger().log(message: 'Running HTTP server on localhost:${server.port}');

    await for (HttpRequest request in server) {
      globalLocator<TrezorHttpController>().handleRequest(request);
    }
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
