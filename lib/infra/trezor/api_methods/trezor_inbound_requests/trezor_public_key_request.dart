import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/get_public_key.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/trezor_public_key_response.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:mirage/shared/utils/cbor_utils.dart';

class TrezorPublicKeyRequest extends ATrezorInboundRequest {
  final List<CborPathComponent> cborDerivationPath;
  final List<int> _numericDerivationPath;
  final String _stringDerivationPath;

  TrezorPublicKeyRequest({
    required this.cborDerivationPath,
    required List<int> numericDerivationPath,
    required String stringDerivationPath,
  })  : _numericDerivationPath = numericDerivationPath,
        _stringDerivationPath = stringDerivationPath;

  factory TrezorPublicKeyRequest.fromDto(GetPublicKey getPublicKey) {
    List<CborPathComponent> cborDerivationPath = CborUtils.pathToCbor(getPublicKey.path);

    return TrezorPublicKeyRequest(
      cborDerivationPath: cborDerivationPath,
      numericDerivationPath: cborDerivationPath.map((CborPathComponent e) => e.index).toList(),
      stringDerivationPath: getPublicKey.path,
    );
  }

  TrezorPublicKeyResponse fromSecp256k1PublicKey(Secp256k1PublicKey secp256k1publicKey) {
    return TrezorPublicKeyResponse(
      depth: cborDerivationPath.length,
      fingerprint: secp256k1publicKey.metadata.parentFingerprint!.toInt(),
      chainCode: BytesUtils.convertBytesToHex(secp256k1publicKey.metadata.chainCode!),
      publicKey: BytesUtils.convertBytesToHex(secp256k1publicKey.compressed),
      xpub: secp256k1publicKey.getExtendedPublicKey(),
      stringDerivationPath: _stringDerivationPath,
      numericDerivationPath: _numericDerivationPath,
    );
  }

  @override
  List<String> get description => <String>[
        'open Snggle',
        'click "Connect wallet" button with "Audio interface" selected',
        'emit audio',
      ];

  @override
  Uint8List toSerializedCbor() {
    CborCryptoKeypath cborCryptoKeypath = CborCryptoKeypath(components: cborDerivationPath);
    return cborCryptoKeypath.toSerializedCbor(includeTagBool: true);
  }

  @override
  Future<TrezorPublicKeyResponse> getResponseFromCborPayload(Uint8List payloadBytes) async {
    return TrezorPublicKeyResponse.fromSerializedCbor(payloadBytes, _numericDerivationPath, _stringDerivationPath);
  }

  @override
  String get title => 'Exporting Public Key';

  @override
  List<Object?> get props => <Object>[cborDerivationPath];
}
