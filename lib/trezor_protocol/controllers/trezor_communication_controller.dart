import 'dart:async';

import 'package:mirage/trezor_protocol/shared/protobuf/protobuf_msg_serializer.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/automated/a_trezor_automated_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

class TrezorCommunicationController {
  Future<String> handleBuffer(String inputBuffer) async {
    protobuf.GeneratedMessage inputMsg = ProtobufMsgSerializer.deserialize(inputBuffer);
    protobuf.GeneratedMessage responseMsg = await _handleProtobufMsg(inputMsg);
    return ProtobufMsgSerializer.serialize(responseMsg);
  }

  Future<protobuf.GeneratedMessage> _handleProtobufMsg(protobuf.GeneratedMessage inputMsg) async {
    ATrezorInboundRequest trezorInboundRequest = ATrezorInboundRequest.fromProtobufMsg(inputMsg);
    ATrezorOutboundResponse trezorOutboundResponse = await _handleTrezorRequest(trezorInboundRequest);
    return trezorOutboundResponse.toProtobufMsg();
  }

  Future<ATrezorOutboundResponse> _handleTrezorRequest(ATrezorInboundRequest trezorInboundRequest) async {
    switch (trezorInboundRequest) {
      case ATrezorAutomatedRequest trezorAutomatedRequest:
        ATrezorOutboundResponse trezorOutboundResponse = trezorAutomatedRequest.getResponse();
        return trezorOutboundResponse;
      case ATrezorInteractiveRequest trezorInteractiveRequest:
        // TODO(Marcin): replace prompt data input with Audio Protocol implementation
        ATrezorAwaitedResponse trezorAwaitedResponse = trezorInteractiveRequest.getResponseFromUser();
        return trezorAwaitedResponse;
      default:
        throw ArgumentError();
    }
  }
}
