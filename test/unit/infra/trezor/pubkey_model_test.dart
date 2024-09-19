import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/infra/entity/pubkey_entity.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

void main() {
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
