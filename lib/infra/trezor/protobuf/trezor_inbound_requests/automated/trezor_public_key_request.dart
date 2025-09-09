import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/automated/a_trezor_automated_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';

class TrezorPublicKeyRequest extends ATrezorAutomatedRequest {
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
  List<Object?> get props => <Object>[derivationPath];

  @override
  ATrezorOutboundResponse getResponse({Secp256k1PublicKey? secp256k1publicKey}) {
    if (secp256k1publicKey == null) {
      throw Exception('secp256k1publicKey is required for public key export');
    }
    if (derivationPath.length == 4) {
      return TrezorPublicKeyResponse(
        depth: derivationPath.length,
        fingerprint: secp256k1publicKey.metadata.parentFingerprint!.toInt(),
        chainCode: secp256k1publicKey.metadata.chainCode!,
        publicKey: secp256k1publicKey.compressed,
        xpub: secp256k1publicKey.getExtendedPublicKey(),
      );
    }
    else {
      Secp256k1Derivator secp256k1Derivator = Secp256k1Derivator();
      Secp256k1PublicKey derivedSecp256k1PubKey = secp256k1Derivator.derivePublicKey(
        secp256k1publicKey,
        LegacyDerivationPathElement.fromShiftedIndex(derivationPath.last),
      );
      return TrezorPublicKeyResponse(
        depth: derivationPath.length,
        fingerprint: derivedSecp256k1PubKey.metadata.parentFingerprint!.toInt(),
        chainCode: derivedSecp256k1PubKey.metadata.chainCode!,
        publicKey: derivedSecp256k1PubKey.compressed,
        xpub: derivedSecp256k1PubKey.getExtendedPublicKey(),
      );
    }
  }
}
