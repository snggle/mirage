import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/infra/entity/pubkey_entity.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

void main() {
  group('Tests of PubkeyModel.derive() method', () {
    test('Should [return derived public key] according to given [shifted index]', () {
      // Arrange
      PubkeyModel actualPubkeyModel = PubkeyModel.fromEntity(
        const PubkeyEntity(
          xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
        ),
      );

      // Act
      PubkeyModel actualDerivedPubkeyModel = actualPubkeyModel.derive(0);

      // Assert
      PubkeyModel expectedDerivedPubkeyModel = PubkeyModel(
          secp256k1publicKey: Secp256k1PublicKey.fromExtendedPublicKey(
              'xpub6GTZvMtLoeTYGYuLUMGbDiKnDQr3HvpTtbWjAXroWEdDfjRtHNPJy1E2fpSyJPCPjNLf8S61P7eTAHFGcWDzUqTmAiPs5nSPtzoLCEyAtiE'));

      expect(actualDerivedPubkeyModel, expectedDerivedPubkeyModel);
    });
  });

  group('Tests of PubkeyModel.ethereumAddress getter', () {
    test('Should [return Ethereum address]', () {
      // Arrange
      PubkeyModel actualPubkeyModel = PubkeyModel.fromEntity(
        const PubkeyEntity(
          xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
        ),
      );

      // Act
      String actualHex = actualPubkeyModel.ethereumAddress;

      // Assert
      String expectedHex = '0xC25B7bdC158ED3d536d38518c75761CE410d5679';

      expect(actualHex, expectedHex);
    });
  });

  group('Tests of PubkeyModel.hex getter', () {
    test('Should [return public key] as HEX', () {
      // Arrange
      PubkeyModel actualPubkeyModel = PubkeyModel.fromEntity(
        const PubkeyEntity(
          xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
        ),
      );

      // Act
      String actualHex = actualPubkeyModel.hex;

      // Assert
      String expectedHex = '0240e7ecb2364c6195aa6b1abfe8dd5f01aa5904626e2b5517781d97ffd8cd4d8f';

      expect(actualHex, expectedHex);
    });
  });
}
