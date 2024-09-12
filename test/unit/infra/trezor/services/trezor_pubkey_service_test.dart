import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/infra/entity/pubkey_entity.dart';
import 'package:mirage/infra/services/pubkey_service.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

import '../../../../mocks/mock_locator.dart';
import '../../../../utils/test_utils.dart';

Future<void> main() async {
  await initMockLocator();

  group('Tests of TrezorPubkeyService.getDerivedPublicKey()', () {
    test('Should [return derived public key] according to given [derivation index]', () async {
      // Arrange
      await TestUtils.initWithTestPubkey();
      PubkeyService actualTrezorPubkeyService = PubkeyService();
      int derivationIndex = 0;

      // Act
      PubkeyModel actualDerivedPublicKey = await actualTrezorPubkeyService.getDerivedPublicKey(derivationIndex);

      // Assert
      PubkeyModel expectedDerivedPublicKey = PubkeyModel(
          secp256k1publicKey: Secp256k1PublicKey.fromExtendedPublicKey(
              'xpub6GTZvMtLoeTYGYuLUMGbDiKnDQr3HvpTtbWjAXroWEdDfjRtHNPJy1E2fpSyJPCPjNLf8S61P7eTAHFGcWDzUqTmAiPs5nSPtzoLCEyAtiE'));

      expect(actualDerivedPublicKey, expectedDerivedPublicKey);
    });
  });

  group('Tests of TrezorPubkeyService.getPublicKey()', () {
    test('Should [return PubkeyModel] if [file EXISTS] and its [content NOT EMPTY]', () async {
      // Arrange
      await TestUtils.initWithTestPubkey();
      PubkeyService actualTrezorPubkeyService = PubkeyService();

      // Act
      PubkeyModel pubKeyModel = await actualTrezorPubkeyService.getPublicKey();

      // Assert
      PubkeyModel expectedPubKeyModel = PubkeyModel.fromEntity(
        const PubkeyEntity(
          xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
        ),
      );

      expect(pubKeyModel, expectedPubKeyModel);
    });

    test('Should [throw Exception] if [file EXISTS] but its [content EMPTY]', () async {
      // Arrange
      PubkeyService actualTrezorPubkeyService = PubkeyService();
      await TestUtils.saveMockedPublicKey(<String, dynamic>{});

      // Assert
      expect(
            () async => actualTrezorPubkeyService.getPublicKey(),
        throwsA(isA<Exception>()),
      );
    });

    test('Should [throw Exception] if [file NOT EXISTS]', () async {
      // Arrange
      PubkeyService actualTrezorPubkeyService = PubkeyService();

      // Assert
      expect(
            () async => actualTrezorPubkeyService.getPublicKey(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Tests of TrezorPubkeyService.saveXPub()', () {
    test('Should [save the file] with xpub', () async {
      // Arrange
      PubkeyService actualTrezorPubkeyService = PubkeyService();
      String actualXpub = 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s';

      // Act
      await actualTrezorPubkeyService.saveXPub(actualXpub);

      PubkeyEntity actualSavedPubkey = await TestUtils.getMockedPublicKey();

      // Assert
      PubkeyEntity expectedSavedPubkey = const PubkeyEntity(
        xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
      );

      expect(actualSavedPubkey, expectedSavedPubkey);
    });
  });

  tearDown(TestUtils.deleteMockedPublicKey);
}
