import 'package:cryptography_utils/cryptography_utils.dart' as cryptography_utils;
import 'package:equatable/equatable.dart';
import 'package:mirage/infra/trezor/entity/pubkey_entity.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';

class PubkeyModel extends Equatable {
  final cryptography_utils.Secp256k1PublicKey secp256k1publicKey;

  const PubkeyModel({
    required this.secp256k1publicKey,
  });

  factory PubkeyModel.fromEntity(PubkeyEntity savedPubkey) {
    return PubkeyModel(
      secp256k1publicKey: cryptography_utils.Secp256k1PublicKey.fromExtendedPublicKey(savedPubkey.xpub),
    );
  }

  String derivePublicAddress(List<int> derivationPath) {
    cryptography_utils.Secp256k1Derivator secp256k1Derivator = cryptography_utils.Secp256k1Derivator();

    cryptography_utils.Secp256k1PublicKey derivedSecp256k1publicKey =
        secp256k1Derivator.derivePublicKey(secp256k1publicKey, cryptography_utils.LegacyDerivationPathElement.parse(derivationPath.last.toString()));

    cryptography_utils.EthereumAddressEncoder ethereumAddressEncoder = cryptography_utils.EthereumAddressEncoder();
    return ethereumAddressEncoder.encodePublicKey(derivedSecp256k1publicKey);
  }

  String get publicAddressHex => BytesUtils.convertBytesToHex(secp256k1publicKey.compressed);

  @override
  List<Object?> get props => <Object>[secp256k1publicKey];
}
