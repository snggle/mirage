import 'package:get_it/get_it.dart';
import 'package:mirage/infra/trezor/repositories/pubkey_repository.dart';
import 'package:mirage/infra/trezor/trezor_communication_notifier.dart';

final GetIt globalLocator = GetIt.I;

Future<void> initMockLocator() async {
  globalLocator
    ..registerLazySingleton<PubkeyRepository>(() => PubkeyRepository('test/mocks/tmp'))
    ..registerLazySingleton<TrezorCommunicationNotifier>(TrezorCommunicationNotifier.new);
}
