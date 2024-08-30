import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/entity/pubkey_entity.dart';
import 'package:mirage/infra/trezor/public_key_model.dart';
import 'package:mirage/infra/trezor/repositories/pubkey_repository.dart';

class PubkeyService {
  final PubkeyRepository _pubkeyRepository = globalLocator<PubkeyRepository>();

  Future<void> saveXPub(String xpub) async {
    await _pubkeyRepository.save(<String, dynamic>{'xpub': xpub});
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
