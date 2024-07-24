import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';

abstract class ATrezorAwaitedResponse extends ATrezorOutboundResponse {
  @override
  List<Object?> get props => <Object>[];
}
