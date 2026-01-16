import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';
import 'package:mirage/infra/trezor/api_methods/dto/api_method_parser.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/ws/trezor_ws_event.dart';

class TrezorWsCommunicationNotifier extends ChangeNotifier {
  TrezorWsEvent? activeEvent;

  Future<Map<String, dynamic>> getResponsePayload(Map<String, dynamic> payloadMap) async {
    AApiMethodDto wsPayloadDto = ApiMethodParser.fromWsPayloadJson(payloadMap);
    ATrezorInboundRequest trezorInboundRequest = ATrezorInboundRequest.fromDto(wsPayloadDto);
    ATrezorOutboundResponse trezorOutboundResponse = await _processEvent(TrezorWsEvent(trezorInboundRequest));

    return trezorOutboundResponse.toDto().toJson();
  }

  Future<ATrezorOutboundResponse> _processEvent(TrezorWsEvent event) async {
    activeEvent?.reject('Event overwritten');
    activeEvent = event;
    notifyListeners();

    try {
      ATrezorOutboundResponse trezorOutboundResponse = await event.future;
      return trezorOutboundResponse;
    } catch (error) {
      rethrow;
    } finally {
      activeEvent = null;
      notifyListeners();
    }
  }
}
