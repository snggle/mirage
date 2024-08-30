import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mirage/infra/trezor/protobuf/protobuf_msg_serializer.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/automated/a_trezor_automated_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/trezor_event.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

class TrezorCommunicationNotifier extends ChangeNotifier {
  TrezorEvent? activeEvent;

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
        ATrezorOutboundResponse trezorOutboundResponse = await _handleAutomatedRequest(trezorAutomatedRequest);
        return trezorOutboundResponse;
      case ATrezorInteractiveRequest trezorInteractiveRequest:
        ATrezorAwaitedResponse trezorAwaitedResponse = await _handleInteractiveRequest(trezorInteractiveRequest);
        return trezorAwaitedResponse;
      default:
        throw ArgumentError();
    }
  }

  Future<ATrezorOutboundResponse> _handleAutomatedRequest(ATrezorAutomatedRequest trezorAutomatedRequest) async {
    return trezorAutomatedRequest.getResponse();
  }

  Future<ATrezorAwaitedResponse> _handleInteractiveRequest(ATrezorInteractiveRequest trezorInteractiveRequest) async {
    ATrezorAwaitedResponse trezorAwaitedResponse = await _processEvent(TrezorEvent(trezorInteractiveRequest));

    return trezorAwaitedResponse;
  }

  Future<ATrezorAwaitedResponse> _processEvent(TrezorEvent event) async {
    activeEvent?.reject('Event overwritten');
    activeEvent = event;
    notifyListeners();

    try {
      ATrezorAwaitedResponse trezorAwaitedResponse = await event.future;
      return trezorAwaitedResponse;
    } catch (error) {
      rethrow;
    } finally {
      activeEvent = null;
      notifyListeners();
    }
  }
}
