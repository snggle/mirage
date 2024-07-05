import 'package:get_it/get_it.dart';
import 'package:mirage/trezor_protocol/controllers/trezor_communication_controller.dart';

final GetIt globalLocator = GetIt.I;

Future<void> initLocator() async {
  globalLocator.registerLazySingleton<TrezorCommunicationController>(TrezorCommunicationController.new);
}
