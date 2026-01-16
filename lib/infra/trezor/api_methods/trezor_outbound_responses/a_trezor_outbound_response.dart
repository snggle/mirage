import 'package:equatable/equatable.dart';
import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';

abstract class ATrezorOutboundResponse extends Equatable {
  AApiMethodDto toDto();
}
