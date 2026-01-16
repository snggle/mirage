import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';
import 'package:mirage/infra/trezor/api_methods/dto/outbound/eth_signed_msg.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';

class TrezorEthMsgSignatureResponse extends ATrezorOutboundResponse {
  final String address;
  final String signature;

  TrezorEthMsgSignatureResponse({
    required this.address,
    required this.signature,
  });

  factory TrezorEthMsgSignatureResponse.fromSerializedCbor(Uint8List serializedCbor, String address) {
    CborEthSignature cborEthSignature = CborEthSignature.fromSerializedCbor(serializedCbor);

    return TrezorEthMsgSignatureResponse(
      address: address,
      signature: BytesUtils.convertBytesToHex(cborEthSignature.signature),
    );
  }

  @override
  AApiMethodDto toDto() {
    return EthSignedMsg(address: address, signature: signature);
  }

  @override
  List<Object?> get props => <Object>[address, signature];
}
