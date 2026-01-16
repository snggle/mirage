import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';
import 'package:mirage/infra/trezor/api_methods/dto/outbound/eth_signed_tx.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';

class TrezorEIP1559SignatureResponse extends ATrezorOutboundResponse {
  final String signatureR;
  final String signatureS;
  final String signatureV;

  TrezorEIP1559SignatureResponse({
    required this.signatureR,
    required this.signatureS,
    required this.signatureV,
  });

  factory TrezorEIP1559SignatureResponse.fromSerializedCbor(Uint8List serializedCbor) {
    CborEthSignature urRegistryEthSignature = CborEthSignature.fromSerializedCbor(serializedCbor);
    Uint8List signature = urRegistryEthSignature.signature;

    return TrezorEIP1559SignatureResponse(
      signatureR: '0x${BytesUtils.convertBytesToHex(signature.sublist(0, 32))}',
      signatureS: '0x${BytesUtils.convertBytesToHex(signature.sublist(32, 64))}',
      signatureV: '0x${BytesUtils.convertBytesToHex(Uint8List.fromList(<int>[signature[64]]))}',
    );
  }

  @override
  AApiMethodDto toDto() {
    return EthSignedTx(
      r: signatureR,
      s: signatureS,
      v: signatureV,
    );
  }

  @override
  List<Object?> get props => <Object>[signatureR, signatureS, signatureV];
}
