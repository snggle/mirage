import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_sign_msg.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_sign_tx.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/get_public_key.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_eip1559_signature_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_eth_msg_signature_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_public_key_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';

abstract class ATrezorInboundRequest extends Equatable {
  static ATrezorInboundRequest fromDto(AApiMethodDto wsPayloadDto) {
    switch (wsPayloadDto) {
      case GetPublicKey _:
        return TrezorPublicKeyRequest.fromDto(wsPayloadDto);
      case EthSignTx _:
        return TrezorEIP1559SignatureRequest.fromDto(wsPayloadDto);
      case EthSignMsg _:
        return TrezorEthMsgSignatureRequest.fromDto(wsPayloadDto);
      default:
        throw ArgumentError();
    }
  }

  List<String> get description;

  Uint8List toSerializedCbor();

  Future<ATrezorOutboundResponse> getResponseFromCborPayload(Uint8List payloadBytes);

  String get title;
}
