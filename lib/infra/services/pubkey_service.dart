import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/entity/pubkey_entity.dart';
import 'package:mirage/infra/repositories/pubkey_repository.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

class PubkeyService {
  final PubkeyRepository _pubkeyRepository = globalLocator<PubkeyRepository>();

  Future<PubkeyModel> getDerivedPublicKey(int derivationIndex) async {
    PubkeyModel pubkeyModel = await getPublicKey();
    return pubkeyModel.derive(derivationIndex);
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
