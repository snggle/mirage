import 'package:flutter/material.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/trezor_communication_notifier.dart';
import 'package:mirage/infra/trezor/trezor_http_server.dart';
import 'package:mirage/views/pages/main_page_wrapper.dart';

Future<void> main() async {
  await initLocator();
  await globalLocator<TrezorCommunicationNotifier>().init();

  TrezorHttpServer trezorHttpServer = TrezorHttpServer();
  try {
    await trezorHttpServer.start();
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
      title: 'Mirage Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPageWrapper(),
    );
  }
}
