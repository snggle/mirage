import 'package:get_it/get_it.dart';
import 'package:mirage/infra/repositories/pubkey_repository.dart';
import 'package:mirage/infra/services/pubkey_service.dart';
import 'package:mirage/infra/trezor/trezor_communication_notifier.dart';

final GetIt globalLocator = GetIt.I;

Future<void> initLocator() async {
  globalLocator
    ..registerLazySingleton<PubkeyRepository>(() => PubkeyRepository('storage'))
    ..registerLazySingleton<PubkeyService>(PubkeyService.new)
    ..registerLazySingleton<TrezorCommunicationNotifier>(TrezorCommunicationNotifier.new);
}
