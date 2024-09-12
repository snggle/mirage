import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorEthMsgSignatureResponse extends ATrezorAwaitedResponse {
  final String address;
  final List<int> signature;

  TrezorEthMsgSignatureResponse({
    required this.address,
    required this.signature,
  });

  factory TrezorEthMsgSignatureResponse.fromSerializedCbor(Uint8List serializedCbor, String address) {
    CborEthSignature cborEthSignature = CborEthSignature.fromSerializedCbor(serializedCbor);

    return TrezorEthMsgSignatureResponse(
      address: address,
      signature: cborEthSignature.signature,
    );
  }

  @override
  GeneratedMessage toProtobufMsg() {
    return EthereumMessageSignature(
      address: address,
      signature: signature,
    );
  }

  @override
  List<Object?> get props => <Object>[address, signature];
}
