import 'package:get_it/get_it.dart';
import 'package:mirage/infra/trezor/trezor_communication_notifier.dart';

final GetIt globalLocator = GetIt.I;

Future<void> initLocator() async {
  globalLocator.registerLazySingleton<TrezorCommunicationNotifier>(TrezorCommunicationNotifier.new);
}
