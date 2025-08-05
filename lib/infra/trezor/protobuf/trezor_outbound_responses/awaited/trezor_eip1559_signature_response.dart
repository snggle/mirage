import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorEIP1559SignatureResponse extends ATrezorAwaitedResponse {
  final List<int> signatureR;
  final List<int> signatureS;
  final int signatureV;

  TrezorEIP1559SignatureResponse({
    required this.signatureR,
    required this.signatureS,
    required this.signatureV,
  });

  factory TrezorEIP1559SignatureResponse.fromSerializedCbor(Uint8List serializedCbor) {
    CborEthSignature urRegistryEthSignature = CborEthSignature.fromSerializedCbor(serializedCbor);
    Uint8List signature = urRegistryEthSignature.signature;

    return TrezorEIP1559SignatureResponse(
      signatureR: signature.sublist(0, 32),
      signatureS: signature.sublist(32, 64),
      signatureV: signature[64],
    );
  }

  @override
  GeneratedMessage toProtobufMsg() {
    return EthereumTxRequest(
      signatureR: signatureR,
      signatureS: signatureS,
      signatureV: signatureV,
    );
  }

  @override
  List<Object?> get props => <Object>[signatureR, signatureS, signatureV];
}
