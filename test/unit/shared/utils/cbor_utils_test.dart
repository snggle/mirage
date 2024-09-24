import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/shared/utils/cbor_utils.dart';

void main() {
  group('Tests of CborUtils.getXPub()', () {
    test('Should [return xPub] according to given CborCryptoHDKey', () {
      // Arrange
      CborCryptoHDKey actualCborCryptoHDKey = CborCryptoHDKey(
        isMaster: true,
        isPrivate: false,
        // @formatter:off
        keyData: Uint8List.fromList(<int>[2, 64, 231, 236, 178, 54, 76, 97, 149, 170, 107, 26, 191, 232, 221, 95, 1, 170, 89, 4, 98, 110, 43, 85, 23, 120, 29, 151, 255, 216, 205, 77, 143]),
        chainCode: Uint8List.fromList(<int>[26, 71, 127, 250, 21, 9, 64, 23, 141, 109, 147, 72, 253, 186, 221, 234, 205, 101, 74, 26, 15, 192, 247, 255, 7, 222, 59, 86, 93, 189, 166, 49]),
        // // @formatter:on
        origin: const CborCryptoKeypath(components: <CborPathComponent>[
          CborPathComponent(index: 44, hardened: true),
          CborPathComponent(index: 60, hardened: true),
          CborPathComponent(index: 0, hardened: true),
          CborPathComponent(index: 0, hardened: false),
        ]),
        parentFingerprint: 1881575369,
      );

      // Act
      String actualXPub = CborUtils.getXPub(actualCborCryptoHDKey);

      // Assert
      String expectedXPub = 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s';

      expect(actualXPub, expectedXPub);
    });
  });

  group('Tests of CborUtils.convertToPathComponents()', () {
    test('Should [return List<CborPathComponent>] according to given numeric derivation path', () {
      // Arrange
      List<int> numericDerivationPath = <int>[2147483692, 2147483708, 2147483648, 0];

      // Act
      List<CborPathComponent> actualCborPathComponents = CborUtils.convertToPathComponents(numericDerivationPath);

      // Assert
      List<CborPathComponent> expectedCborPathComponents = <CborPathComponent>[
        const CborPathComponent(index: 44, hardened: true),
        const CborPathComponent(index: 60, hardened: true),
        const CborPathComponent(index: 0, hardened: true),
        const CborPathComponent(index: 0, hardened: false),
      ];

      expect(actualCborPathComponents, expectedCborPathComponents);
    });
  });
}
