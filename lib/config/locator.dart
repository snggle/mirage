import 'package:get_it/get_it.dart';
import 'package:mirage/controllers/protobuf_controller.dart';
import 'package:mirage/controllers/trezor_http_controller.dart';

final GetIt globalLocator = GetIt.I;

Future<void> initLocator() async {
  globalLocator
    ..registerLazySingleton<ProtobufController>(ProtobufController.new)
    ..registerLazySingleton<TrezorHttpController>(TrezorHttpController.new);
}
