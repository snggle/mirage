import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/infra/trezor/entity/pubkey_entity.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';
import 'package:mirage/infra/trezor/public_key_model.dart';
import 'package:mirage/infra/trezor/services/pubkey_service.dart';

import '../../../../mocks/mock_locator.dart';
import '../../../../utils/test_utils.dart';

Future<void> main() async {
  await initMockLocator();
  tearDown(TestUtils.deleteMockedPublicKey);

  group('Tests of TrezorPubkeyService.saveXPub()', () {
    test('Should [save the file] with xpub', () async {
      // Arrange
      PubkeyService actualTrezorPubkeyService = PubkeyService();

      TrezorPublicKeyResponse actualTrezorPublicKeyResponse = TrezorPublicKeyResponse(
        depth: 4,
        fingerprint: 1881575369,
        // @formatter:off
        chainCode: const <int>[26, 71, 127, 250, 21, 9, 64, 23, 141, 109, 147, 72, 253, 186, 221, 234, 205, 101, 74, 26, 15, 192, 247, 255, 7, 222, 59, 86, 93, 189, 166, 49],
        publicKey: const <int>[2, 64, 231, 236, 178, 54, 76, 97, 149, 170, 107, 26, 191, 232, 221, 95, 1, 170, 89, 4, 98, 110, 43, 85, 23, 120, 29, 151, 255, 216, 205, 77, 143],
        // @formatter:on
        xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
      );

      // Act
      await actualTrezorPubkeyService.saveXPub(actualTrezorPublicKeyResponse.xpub);

      PubkeyEntity actualSavedPubkey = await TestUtils.getMockedPublicKey();

      // Assert
      PubkeyEntity expectedSavedPubkey = const PubkeyEntity(
        xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
      );

      expect(actualSavedPubkey, expectedSavedPubkey);
    });
  });

  group('Tests of TrezorPubkeyService.getPublicKey', () {
    test('Should [return last PubkeyModel]', () async {
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

    test('Should [throw Exception] if file content empty', () async {
      // Arrange
      PubkeyService actualTrezorPubkeyService = PubkeyService();
      await TestUtils.saveMockedPublicKey(<String, dynamic>{});

      // Assert
      expect(
        () async => actualTrezorPubkeyService.getPublicKey(),
        throwsA(isA<Exception>()),
      );
    });

    test('Should [throw Exception] if file empty', () async {
      // Arrange
      PubkeyService actualTrezorPubkeyService = PubkeyService();
      await TestUtils.deleteMockedPublicKey();

      // Assert
      expect(
        () async => actualTrezorPubkeyService.getPublicKey(),
        throwsA(isA<Exception>()),
      );
    });
  });
}