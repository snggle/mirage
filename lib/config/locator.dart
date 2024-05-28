import 'package:get_it/get_it.dart';
import 'package:mirage/trezor_protocol/controllers/trezor_communication_controller.dart';
import 'package:mirage/trezor_protocol/controllers/trezor_http_controller.dart';

final GetIt globalLocator = GetIt.I;

Future<void> initLocator() async {
  globalLocator
    ..registerLazySingleton<TrezorHttpController>(TrezorHttpController.new)
    ..registerLazySingleton<TrezorCommunicationController>(TrezorCommunicationController.new);
}
