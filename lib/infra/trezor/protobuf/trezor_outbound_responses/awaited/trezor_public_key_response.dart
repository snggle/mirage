import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-common.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/shared/utils/cbor_utils.dart';
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

  factory TrezorPublicKeyResponse.fromSerializedCbor(Uint8List serializedCbor) {
    CborCryptoHDKey cborCryptoHDKey = CborCryptoHDKey.fromSerializedCbor(serializedCbor);

    return TrezorPublicKeyResponse(
      depth: cborCryptoHDKey.origin!.components.length,
      fingerprint: cborCryptoHDKey.parentFingerprint!,
      chainCode: cborCryptoHDKey.chainCode!,
      publicKey: cborCryptoHDKey.keyData,
      xpub: CborUtils.getXPub(cborCryptoHDKey),
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
