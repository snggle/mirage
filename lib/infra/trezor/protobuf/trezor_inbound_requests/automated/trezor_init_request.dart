import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-management.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/automated/a_trezor_automated_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/trezor_properties_response.dart';

class TrezorInitRequest extends ATrezorAutomatedRequest {
  final List<int> sessionId;

  TrezorInitRequest({
    required this.sessionId,
  });

  factory TrezorInitRequest.fromProtobufMsg(Initialize initialize) {
    return TrezorInitRequest(
      sessionId: initialize.sessionId,
    );
  }

  @override
  ATrezorOutboundResponse getResponse() {
    return TrezorPropertiesResponse.defaultResponse(sessionId: sessionId);
  }

  @override
  List<Object?> get props => <Object>[sessionId];
}
