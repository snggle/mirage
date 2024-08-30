import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:mirage/infra/entity/pubkey_entity.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';

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

  String get hex => BytesUtils.convertBytesToHex(secp256k1publicKey.compressed);

  @override
  List<Object?> get props => <Object>[secp256k1publicKey];
}
