import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/entity/pubkey_entity.dart';
import 'package:mirage/infra/repositories/pubkey_repository.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

class PubkeyService {
  final PubkeyRepository _pubkeyRepository = globalLocator<PubkeyRepository>();

  Future<PubkeyModel> getDerivedPublicKey(int derivationIndex) async {
    Secp256k1Derivator secp256k1Derivator = Secp256k1Derivator();

    PubkeyModel pubkeyModel = await getPublicKey();

    Secp256k1PublicKey secp256k1Pubkey = pubkeyModel.secp256k1publicKey;
    Secp256k1PublicKey derivedSecp256k1PubKey = secp256k1Derivator.derivePublicKey(
      secp256k1Pubkey,
      LegacyDerivationPathElement.fromShiftedIndex(derivationIndex),
    );

    return PubkeyModel(secp256k1publicKey: derivedSecp256k1PubKey);
  }

  Future<PubkeyModel> getPublicKey() async {
    try {
      PubkeyEntity pubkeyEntity = await _pubkeyRepository.get();
      return PubkeyModel.fromEntity(pubkeyEntity);
    } catch (e) {
      throw Exception('Cannot read the public key from the file');
    }
  }

  Future<void> saveXPub(String xpub) async {
    await _pubkeyRepository.save(<String, dynamic>{'xpub': xpub});
  }
}
