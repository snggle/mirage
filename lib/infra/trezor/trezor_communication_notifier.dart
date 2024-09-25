import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mirage/infra/trezor/protobuf/protobuf_msg_serializer.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/automated/a_trezor_automated_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/multipart/a_trezor_multipart_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/supplementary/a_trezor_supplementary_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/trezor_event.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

class TrezorCommunicationNotifier extends ChangeNotifier {
  TrezorEvent? activeEvent;
  ATrezorMultipartInteractiveRequest? incompleteEIP1559SignatureRequest;

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
        return _handleAutomatedRequest(trezorAutomatedRequest);
      case ATrezorMultipartInteractiveRequest trezorMultipartInteractiveRequest:
        return _handleMultipartInteractiveRequest(trezorMultipartInteractiveRequest);
      case ATrezorInteractiveRequest trezorInteractiveRequest:
        return _handleInteractiveRequest(trezorInteractiveRequest);
      case ATrezorSupplementaryRequest trezorSupplementaryRequest:
        return _handleTrezorSupplementaryRequest(trezorSupplementaryRequest);
      default:
        throw ArgumentError();
    }
  }

  Future<ATrezorOutboundResponse> _handleAutomatedRequest(ATrezorAutomatedRequest trezorAutomatedRequest) async {
    return trezorAutomatedRequest.getResponse();
  }

  Future<ATrezorOutboundResponse> _handleMultipartInteractiveRequest(ATrezorMultipartInteractiveRequest trezorMultipartInteractiveRequest) async {
    if (trezorMultipartInteractiveRequest.requestReady) {
      ATrezorAwaitedResponse trezorAwaitedResponse = await _handleInteractiveRequest(trezorMultipartInteractiveRequest);
      return trezorAwaitedResponse;
    } else {
      incompleteEIP1559SignatureRequest = trezorMultipartInteractiveRequest;
      return trezorMultipartInteractiveRequest.askForSupplementaryInfo();
    }
  }

  Future<ATrezorAwaitedResponse> _handleInteractiveRequest(ATrezorInteractiveRequest trezorInteractiveRequest) async {
    ATrezorAwaitedResponse trezorAwaitedResponse = await _processEvent(TrezorEvent(trezorInteractiveRequest));

    return trezorAwaitedResponse;
  }

  Future<ATrezorOutboundResponse> _handleTrezorSupplementaryRequest(ATrezorSupplementaryRequest trezorSupplementaryRequest) async {
    ATrezorMultipartInteractiveRequest filledTrezorMultipartInteractiveRequest = incompleteEIP1559SignatureRequest!.fillData(trezorSupplementaryRequest);
    if (filledTrezorMultipartInteractiveRequest.requestReady) {
      ATrezorAwaitedResponse trezorAwaitedResponse = await _handleInteractiveRequest(filledTrezorMultipartInteractiveRequest);
      return trezorAwaitedResponse;
    } else {
      incompleteEIP1559SignatureRequest = filledTrezorMultipartInteractiveRequest;
      return filledTrezorMultipartInteractiveRequest.askForSupplementaryInfo();
    }
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
