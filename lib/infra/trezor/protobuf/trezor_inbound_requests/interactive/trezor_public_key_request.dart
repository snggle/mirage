import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';
import 'package:mirage/shared/utils/cbor_utils.dart';

class TrezorPublicKeyRequest extends ATrezorInteractiveRequest {
  final bool waitingAgreedBool;
  final List<int> derivationPath;

  TrezorPublicKeyRequest({
    required this.waitingAgreedBool,
    required this.derivationPath,
  });

  factory TrezorPublicKeyRequest.fromProtobufMsg(GetPublicKey getPublicKey) {
    return TrezorPublicKeyRequest(
      waitingAgreedBool: false,
      derivationPath: getPublicKey.addressN,
    );
  }

  @override
  List<String> get description => <String>[];

  TrezorPublicKeyResponse getDerivedResponse(Secp256k1PublicKey secp256k1publicKey) {
    return TrezorPublicKeyResponse(
      depth: derivationPath.length,
      fingerprint: secp256k1publicKey.metadata.parentFingerprint!.toInt(),
      chainCode: secp256k1publicKey.metadata.chainCode!,
      publicKey: secp256k1publicKey.compressed,
      xpub: secp256k1publicKey.getExtendedPublicKey(),
    );
  }

  @override
  Uint8List toSerializedCbor() {
    List<CborPathComponent> pathComponents = CborUtils.convertToPathComponents(derivationPath);
    CborCryptoKeypath urRegistryCryptoKeypath = CborCryptoKeypath(components: pathComponents);
    return urRegistryCryptoKeypath.toSerializedCbor(includeTagBool: false);
  }

  @override
  Future<TrezorPublicKeyResponse> getResponseFromCborPayload(String payload) async {
    Uint8List payloadBytes = HexCodec.decode(payload);
    return TrezorPublicKeyResponse.fromSerializedCbor(payloadBytes);
  }

  @override
  String get title => 'Exporting Public Key';

  @override
  List<Object?> get props => <Object>[derivationPath];
}
