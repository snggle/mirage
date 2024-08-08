import 'dart:async';

import 'package:mirage/infra/trezor/protobuf/protobuf_msg_serializer.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/automated/a_trezor_automated_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

class TrezorCommunicationNotifier {
  Future<String> getResponseBuffer(String inputBuffer) async {
    protobuf.GeneratedMessage inputMsg = ProtobufMsgSerializer.deserialize(inputBuffer);
    protobuf.GeneratedMessage responseMsg = await _getResponseProtobufMsg(inputMsg);
    return ProtobufMsgSerializer.serialize(responseMsg);
  }

  Future<protobuf.GeneratedMessage> _getResponseProtobufMsg(protobuf.GeneratedMessage inputMsg) async {
    ATrezorInboundRequest trezorInboundRequest = ATrezorInboundRequest.fromProtobufMsg(inputMsg);
    ATrezorOutboundResponse trezorOutboundResponse = await _selectResponseForRequest(trezorInboundRequest);
    return trezorOutboundResponse.toProtobufMsg();
  }

  Future<ATrezorOutboundResponse> _selectResponseForRequest(ATrezorInboundRequest trezorInboundRequest) async {
    switch (trezorInboundRequest) {
      case ATrezorAutomatedRequest trezorAutomatedRequest:
        ATrezorOutboundResponse trezorOutboundResponse = trezorAutomatedRequest.getResponse();
        return trezorOutboundResponse;
      case ATrezorInteractiveRequest trezorInteractiveRequest:
        // TODO(Marcin): notify about the start of audio emitting/recording process
        ATrezorAwaitedResponse trezorAwaitedResponse = trezorInteractiveRequest.getResponseFromUser();
        return trezorAwaitedResponse;
      default:
        throw ArgumentError();
    }
  }
}
