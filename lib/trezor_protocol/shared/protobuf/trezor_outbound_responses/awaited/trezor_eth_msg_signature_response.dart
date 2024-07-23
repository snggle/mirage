import 'package:cbor/cbor.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorEthMsgSignatureResponse extends ATrezorAwaitedResponse {
  final String address;
  final List<int> signature;

  TrezorEthMsgSignatureResponse({
    required this.address,
    required this.signature,
  });

  factory TrezorEthMsgSignatureResponse.fromCborValue(CborValue cborValue) {
    CborList cborList = cborValue as CborList;

    CborString cborAddress = cborList[0] as CborString;
    CborBytes cborSignature = cborList[1] as CborBytes;

    return TrezorEthMsgSignatureResponse(
      address: cborAddress.toString(),
      signature: cborSignature.bytes,
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
