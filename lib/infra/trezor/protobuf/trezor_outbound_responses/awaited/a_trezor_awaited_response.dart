import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';

abstract class ATrezorAwaitedResponse extends ATrezorOutboundResponse {
  @override
  List<Object?> get props => <Object>[];
}
