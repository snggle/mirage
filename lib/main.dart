import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/trezor_http_server.dart';

Future<void> main() async {
  await initLocator();
  TrezorHttpServer trezorHttpServer = TrezorHttpServer();
  await trezorHttpServer.start();
}
