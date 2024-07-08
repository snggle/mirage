import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-common.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/awaited_request_type.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorAskToWaitResponse extends ATrezorOutboundResponse {
  final AwaitedRequestType awaitedRequestType;

  TrezorAskToWaitResponse({
    required this.awaitedRequestType,
  });

  factory TrezorAskToWaitResponse.publicKey() {
    return TrezorAskToWaitResponse(awaitedRequestType: AwaitedRequestType.publicKey);
  }

  factory TrezorAskToWaitResponse.ethMsgSignature() {
    return TrezorAskToWaitResponse(awaitedRequestType: AwaitedRequestType.ethMsgSignature);
  }

  factory TrezorAskToWaitResponse.eip1559Signature() {
    return TrezorAskToWaitResponse(awaitedRequestType: AwaitedRequestType.eip1559Signature);
  }

  @override
  GeneratedMessage toProtobufMsg() {
    return ButtonRequest(code: AwaitedRequestType.toProtobufEnum(awaitedRequestType));
  }

  @override
  List<Object?> get props => <Object>[awaitedRequestType];
}
