import 'package:get_it/get_it.dart';
import 'package:mirage/blocs/pubkey_cubit/pubkey_cubit.dart';
import 'package:mirage/infra/repositories/pubkey_repository.dart';
import 'package:mirage/infra/services/pubkey_service.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_ws_communication_notifier.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_pb_communication_notifier.dart';

final GetIt globalLocator = GetIt.I;

Future<void> initLocator() async {
  globalLocator
    ..registerLazySingleton<PubkeyRepository>(() => PubkeyRepository('storage'))
    ..registerLazySingleton<PubkeyService>(PubkeyService.new)
    ..registerLazySingleton<PubkeyCubit>(PubkeyCubit.new)
    ..registerLazySingleton<TrezorPbCommunicationNotifier>(TrezorPbCommunicationNotifier.new)
    ..registerLazySingleton<TrezorWsCommunicationNotifier>(TrezorWsCommunicationNotifier.new);
}
