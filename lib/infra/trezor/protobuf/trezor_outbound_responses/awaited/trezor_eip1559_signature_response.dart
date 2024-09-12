import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorEIP1559SignatureResponse extends ATrezorAwaitedResponse {
  final int signatureV;
  final List<int> signatureR;
  final List<int> signatureS;

  TrezorEIP1559SignatureResponse({
    required this.signatureV,
    required this.signatureR,
    required this.signatureS,
  });

  factory TrezorEIP1559SignatureResponse.fromSerializedCbor(Uint8List serializedCbor) {
    CborEthSignature urRegistryEthSignature = CborEthSignature.fromSerializedCbor(serializedCbor);
    Uint8List signature = urRegistryEthSignature.signature;

    return TrezorEIP1559SignatureResponse(
      signatureV: signature[0],
      signatureR: signature.sublist(1, 33),
      signatureS: signature.sublist(33, 65),
    );
  }

  @override
  GeneratedMessage toProtobufMsg() {
    return EthereumTxRequest(
      signatureV: signatureV,
      signatureR: signatureR,
      signatureS: signatureS,
    );
  }

  @override
  List<Object?> get props => <Object>[signatureV, signatureR, signatureS];
}
