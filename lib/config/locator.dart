import 'package:get_it/get_it.dart';
import 'package:mirage/controllers/protobuf_controller.dart';

final GetIt globalLocator = GetIt.I;

Future<void> initLocator() async {
  globalLocator.registerLazySingleton<ProtobufController>(ProtobufController.new);
}
