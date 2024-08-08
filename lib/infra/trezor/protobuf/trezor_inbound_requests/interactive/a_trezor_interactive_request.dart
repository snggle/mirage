import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';

abstract class ATrezorInteractiveRequest extends ATrezorInboundRequest {
  ATrezorAwaitedResponse getResponseFromUser();

  @override
  List<Object?> get props => <Object>[];
}
