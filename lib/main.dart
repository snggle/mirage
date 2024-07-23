import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mirage/trezor_protocol/controllers/trezor_http_controller.dart';
import 'package:mirage/views/pages/main_page.dart';

Future<void> main() async {
  await initLocator();

  try {
    HttpServer server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      21325,
    );

    AppLogger().log(message: 'Running HTTP server on localhost:${server.port}');
    runApp(MyApp(httpServer: server));

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

class MyApp extends StatelessWidget {
  final HttpServer httpServer;
  final TrezorHttpController trezorHttpController = TrezorHttpController();
  MyApp({required this.httpServer, super.key}) {
    httpServer.listen(trezorHttpController.handleRequest);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirage Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainPage(title: 'Mirage Demo Main Page'),
    );
  }
}

