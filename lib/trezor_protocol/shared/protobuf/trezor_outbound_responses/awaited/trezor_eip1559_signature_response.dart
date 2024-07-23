import 'package:cbor/cbor.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
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

  factory TrezorEIP1559SignatureResponse.fromCborValue(CborValue cborValue) {
    CborList cborList = cborValue as CborList;

    CborSmallInt cborSignatureV = cborList[0] as CborSmallInt;
    CborBytes cborSignatureR = cborList[1] as CborBytes;
    CborBytes cborSignatureS = cborList[2] as CborBytes;

    return TrezorEIP1559SignatureResponse(
      signatureV: cborSignatureV.value,
      signatureR: cborSignatureR.bytes,
      signatureS: cborSignatureS.bytes,
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
