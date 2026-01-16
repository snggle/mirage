import 'package:flutter/material.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/ws/trezor_ws_server.dart';
import 'package:mirage/views/pages/main_page_wrapper.dart';

Future<void> main() async {
  await initLocator();

  TrezorWsServer trezorWsServer = TrezorWsServer();
  try {
    await trezorWsServer.start();
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
      home: const MainPageWrapper(),
    );
  }
}
