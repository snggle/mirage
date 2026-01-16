import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';
import 'package:mirage/infra/trezor/api_methods/dto/outbound/public_key_response.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';

import 'package:mirage/shared/utils/cbor_utils.dart';

class TrezorPublicKeyResponse extends ATrezorOutboundResponse {
  final int depth;
  final int fingerprint;
  final String chainCode;
  final String publicKey;
  final String xpub;
  final String stringDerivationPath;
  final List<int> numericDerivationPath;

  TrezorPublicKeyResponse({
    required this.depth,
    required this.fingerprint,
    required this.chainCode,
    required this.publicKey,
    required this.xpub,
    required this.stringDerivationPath,
    required this.numericDerivationPath,
  });

  factory TrezorPublicKeyResponse.fromSerializedCbor(Uint8List serializedCbor, List<int> numericDerivationPath, String stringDerivationPath) {
    CborCryptoHDKey cborCryptoHDKey = CborCryptoHDKey.fromSerializedCbor(serializedCbor);

    return TrezorPublicKeyResponse(
      depth: cborCryptoHDKey.origin!.components.length,
      fingerprint: cborCryptoHDKey.parentFingerprint!,
      chainCode: BytesUtils.convertBytesToHex(cborCryptoHDKey.chainCode!),
      publicKey: BytesUtils.convertBytesToHex(cborCryptoHDKey.keyData),
      xpub: CborUtils.getXPub(cborCryptoHDKey),
      stringDerivationPath: stringDerivationPath,
      numericDerivationPath: numericDerivationPath,
    );
  }

  @override
  List<Object?> get props => <Object>[depth, fingerprint, chainCode, publicKey, xpub, stringDerivationPath, numericDerivationPath];

  @override
  AApiMethodDto toDto() {
    return PublicKeyResponse(
      path: numericDerivationPath,
      serializedPath: stringDerivationPath,
      childNum: 0,
      xpub: xpub,
      chainCode: chainCode,
      publicKey: publicKey,
      fingerprint: fingerprint,
      depth: depth,
    );
  }
}
