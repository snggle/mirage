import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/repositories/pubkey_repository.dart';
import 'package:mirage/infra/trezor/entity/pubkey_entity.dart';
import 'package:mirage/infra/trezor/public_key_model.dart';

class PubkeyService {
  final PubkeyRepository _pubkeyRepository = globalLocator<PubkeyRepository>();

  Future<void> saveXPub(String xpub) async {
    await _pubkeyRepository.save(<String, dynamic>{'xpub': xpub});
  }

  Future<PubkeyModel> getDerivedPublicKey(int derivationIndex) async {
    Secp256k1Derivator secp256k1Derivator = Secp256k1Derivator();

    PubkeyModel savedPubkeyModel = await getPublicKey();

    Secp256k1PublicKey savedSecp256k1Pubkey = savedPubkeyModel.secp256k1publicKey;
    Secp256k1PublicKey derivedSecp256k1PubKey = secp256k1Derivator.derivePublicKey(
      savedSecp256k1Pubkey,
      LegacyDerivationPathElement.fromShiftedIndex(derivationIndex),
    );

    return PubkeyModel(secp256k1publicKey: derivedSecp256k1PubKey);
  }

  Future<PubkeyModel> getPublicKey() async {
    try {
      PubkeyEntity savedPubkey = await _pubkeyRepository.get();
      return PubkeyModel.fromEntity(savedPubkey);
    } catch (e) {
      throw Exception('Cannot read the public key from the file');
    }
  }
}
