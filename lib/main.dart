import 'dart:io';

import 'package:mirage/config/locator.dart';
import 'package:mirage/controllers/trezor_http_controller.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  await initLocator();

  try {
    HttpServer server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      21325,
    );

    print('Running HTTP server on localhost:${server.port}');

    await for (HttpRequest request in server) {
      globalLocator<TrezorHttpController>().handleRequest(request);
    }
  } on SocketException catch (e) {
    if (e.osError?.errorCode == 48 || e.osError?.errorCode == 98) {
      print('Port 21325 is already in use. Please close the application using this port or try "sudo fuser -k 21325/tcp".');
    } else {
      print('Failed to bind the HTTP server: $e');
    }
  } catch (e) {
    print('An unexpected error occurred: $e');
  }
}
