import 'package:codec_utils/codec_utils.dart';
import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:mirage/infra/entity/pubkey_entity.dart';

class PubkeyModel extends Equatable {
  final Secp256k1PublicKey secp256k1publicKey;

  const PubkeyModel({
    required this.secp256k1publicKey,
  });

  factory PubkeyModel.fromEntity(PubkeyEntity pubkeyEntity) {
    return PubkeyModel(
      secp256k1publicKey: Secp256k1PublicKey.fromExtendedPublicKey(pubkeyEntity.xpub),
    );
  }

  PubkeyModel derive(int addressShiftedIndex) {
    Secp256k1Derivator secp256k1Derivator = Secp256k1Derivator();
    Secp256k1PublicKey derivedSecp256k1PubKey = secp256k1Derivator.derivePublicKey(
      secp256k1publicKey,
      LegacyDerivationPathElement.fromShiftedIndex(addressShiftedIndex),
    );

    return PubkeyModel(secp256k1publicKey: derivedSecp256k1PubKey);
  }

  String get ethereumAddress {
    EthereumAddressEncoder ethereumAddressEncoder = EthereumAddressEncoder();
    return ethereumAddressEncoder.encodePublicKey(secp256k1publicKey);
  }

  String get hex => HexCodec.encode(secp256k1publicKey.compressed);

  @override
  List<Object?> get props => <Object>[secp256k1publicKey];
}
