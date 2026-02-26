import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';
import 'package:mirage/infra/trezor/api_methods/dto/outbound/error_response.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';

class TrezorErrorResponse extends ATrezorOutboundResponse {
  final String code;
  final String message;

  TrezorErrorResponse({
    required this.code,
    required this.message,
  });

  @override
  AApiMethodDto toDto() {
    return ErrorResponse(
      code: code,
      message: message,
    );
  }

  @override
  List<Object> get props => <Object>[code, message];
}
