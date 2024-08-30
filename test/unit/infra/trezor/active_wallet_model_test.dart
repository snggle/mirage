import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/infra/trezor/entity/pubkey_entity.dart';
import 'package:mirage/infra/trezor/public_key_model.dart';

void main() {
  group('Tests of SavedPubkeyVO.derivePublicAddress', () {
    test('Should [return public address] according to the given derivation path', () {
      // Arrange
      PubkeyModel actualSavedPubkeyVO = PubkeyModel.fromEntity(
        const PubkeyEntity(
          xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
        ),
      );

      List<int> actualDerivationPath = <int>[2147483692, 2147483708, 2147483648, 0, 0];

      // Act
      String actualPublicAddress = actualSavedPubkeyVO.derivePublicAddress(actualDerivationPath);

      // Assert
      String expectedPublicAddress = '0x53Bf0A18754873A8102625D8225AF6a15a43423C';

      expect(actualPublicAddress, expectedPublicAddress);
    });
  });
}
