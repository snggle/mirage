import 'dart:async';

import 'package:mirage/trezor_protocol/shared/protobuf/protobuf_msg_serializer.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/automated/a_trezor_automated_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/a_trezor_supplementary_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

class TrezorCommunicationController {
  ATrezorInteractiveRequest? interactiveRequestInProcess;

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

  Future<ATrezorOutboundResponse> _handleTrezorRequest(ATrezorInboundRequest trezorIncomingRequest) async {
    if (trezorIncomingRequest is ATrezorAutomatedRequest) {
      ATrezorOutboundResponse trezorOutboundResponse = trezorIncomingRequest.getResponse();
      return trezorOutboundResponse;
    }

    if (trezorIncomingRequest is ATrezorInteractiveRequest) {
      interactiveRequestInProcess = trezorIncomingRequest;
    }

    if (trezorIncomingRequest is ATrezorSupplementaryRequest) {
      assert(interactiveRequestInProcess != null, 'Trezor Supplementary Request can occur only after a Trezor Confidential Data Request');

      interactiveRequestInProcess = interactiveRequestInProcess!.fillWithAnotherRequest(trezorIncomingRequest);
    }

    if (interactiveRequestInProcess!.requestReadyBool) {
      // TODO(Marcin): replace prompt data input with Audio Protocol implementation
      ATrezorAwaitedResponse trezorAwaitedResponse = interactiveRequestInProcess!.getResponseFromUser();
      interactiveRequestInProcess = null;
      return trezorAwaitedResponse;
    } else {
      return interactiveRequestInProcess!.askForSupplementaryInfo();
    }
  }
}
