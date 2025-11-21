import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/ws/trezor_ws_server.dart';
import 'package:mirage/views/pages/app_wrapper.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  await initLocator();

  TrezorWsServer trezorWsServer = TrezorWsServer();
  try {
    await trezorWsServer.start();
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows) {
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(700, 700),
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        minimumSize: Size(700, 700),
        maximumSize: Size(800, 700),
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
    runApp(const MyApp());
  } catch (e) {
    throw Exception('Could not start the server');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mirage Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppWrapper(),
    );
  }
}
