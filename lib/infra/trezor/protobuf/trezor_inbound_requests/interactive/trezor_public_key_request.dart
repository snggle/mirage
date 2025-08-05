import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';
import 'package:mirage/shared/utils/cbor_utils.dart';

class TrezorPublicKeyRequest extends ATrezorInteractiveRequest {
  final List<int> derivationPath;

  TrezorPublicKeyRequest({
    required this.derivationPath,
  });

  factory TrezorPublicKeyRequest.fromProtobufMsg(GetPublicKey getPublicKey) {
    return TrezorPublicKeyRequest(
      derivationPath: getPublicKey.addressN,
    );
  }

  @override
  List<String> get description => <String>[
        'open Snggle',
        'click "Connect wallet" button with "Audio interface" selected',
        'emit audio',
      ];

  TrezorPublicKeyResponse fromSecp256k1PublicKey(Secp256k1PublicKey secp256k1publicKey) {
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
    return urRegistryCryptoKeypath.toSerializedCbor(includeTagBool: true);
  }

  @override
  Future<TrezorPublicKeyResponse> getResponseFromCborPayload(Uint8List payloadBytes) async {
    return TrezorPublicKeyResponse.fromSerializedCbor(payloadBytes);
  }

  @override
  String get title => 'Exporting Public Key';

  @override
  List<Object?> get props => <Object>[derivationPath];
}
