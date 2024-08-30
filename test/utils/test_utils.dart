import 'dart:io';

import 'package:mirage/infra/trezor/entity/pubkey_entity.dart';
import 'package:mirage/infra/trezor/repositories/pubkey_repository.dart';

import '../mocks/mock_locator.dart';

class TestUtils {
  static void printInfo(String message) {
    // ignore: avoid_print
    print('\x1B[34m$message\x1B[0m');
  }

  static void printError(String message) {
    // ignore: avoid_print
    print('\x1B[31m$message\x1B[0m');
  }

  static Future<void> saveMockedPublicKey(Map<String, dynamic> content) async {
    PubkeyRepository pubkeyRepository = globalLocator<PubkeyRepository>();
    await pubkeyRepository.save(content);
  }

  static Future<PubkeyEntity> getMockedPublicKey() async {
    PubkeyRepository pubkeyRepository = globalLocator<PubkeyRepository>();
    return pubkeyRepository.get();
  }

  static Future<void> initWithTestPubkey() async {
    PubkeyRepository pubkeyRepository = globalLocator<PubkeyRepository>();
    await pubkeyRepository.save(<String, dynamic>{
      'xpub': 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
    });
  }

  static Future<void> deleteMockedPublicKey() async {
    PubkeyRepository pubkeyRepository = globalLocator<PubkeyRepository>();
    File file = pubkeyRepository.file;
    if (await file.exists()) {
      await file.delete();
    }

    if (await file.parent.exists()) {
      await file.parent.delete();
    }
  }
}
