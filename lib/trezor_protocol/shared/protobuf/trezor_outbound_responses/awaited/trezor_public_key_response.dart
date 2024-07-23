import 'package:cbor/cbor.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-common.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorPublicKeyResponse extends ATrezorAwaitedResponse {
  final int depth;
  final int fingerprint;
  final List<int> chainCode;
  final List<int> publicKey;
  final String xpub;

  TrezorPublicKeyResponse({
    required this.depth,
    required this.fingerprint,
    required this.chainCode,
    required this.publicKey,
    required this.xpub,
  });

  factory TrezorPublicKeyResponse.fromCborValue(CborValue cborValue) {
    CborList cborList = cborValue as CborList;

    CborSmallInt cborDepth = cborList[0] as CborSmallInt;
    CborSmallInt cborFingerprint = cborList[1] as CborSmallInt;
    CborBytes cborChainCode = cborList[2] as CborBytes;
    CborBytes cborPublicKey = cborList[3] as CborBytes;
    CborString cborXpub = cborList[4] as CborString;

    return TrezorPublicKeyResponse(
      depth: cborDepth.value,
      fingerprint: cborFingerprint.value,
      chainCode: cborChainCode.bytes,
      publicKey: cborPublicKey.bytes,
      xpub: cborXpub.toString(),
    );
  }

  @override
  GeneratedMessage toProtobufMsg() {
    return PublicKey(
      node: HDNodeType(
        depth: depth,
        fingerprint: fingerprint,
        childNum: 0,
        chainCode: chainCode,
        publicKey: publicKey,
      ),
      xpub: xpub,
    );
  }

  @override
  List<Object?> get props => <Object>[depth, fingerprint, chainCode, publicKey, xpub];
}
