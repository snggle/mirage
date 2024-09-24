import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/shared/utils/big_int_utils.dart';

void main() {
  group('Tests of BigIntUtils.changeToBytes()', () {
    test('Should [return Endian.big bytes] constructed from given BigInt', () {
      // Arrange
      BigInt actualBigInt = BigInt.parse('1234567890');

      // Act
      Uint8List actualBytes = BigIntUtils.changeToBytes(actualBigInt);

      // Assert
      Uint8List expectedBytes = base64Decode('SZYC0g==');

      expect(actualBytes, expectedBytes);
    });

    test('Should [return padded Endian.big bytes] constructed from given BigInt and length', () {
      // Arrange
      BigInt actualBigInt = BigInt.parse('1234567890');

      // Act
      Uint8List actualBytes = BigIntUtils.changeToBytes(actualBigInt, length: 20);

      // Assert
      Uint8List expectedBytes = base64Decode('AAAAAAAAAAAAAAAAAAAAAEmWAtI=');

      expect(actualBytes, expectedBytes);
    });

    test('Should [return Endian.little bytes] constructed from given BigInt', () {
      // Arrange
      BigInt actualBigInt = BigInt.parse('1234567890');

      // Act
      Uint8List actualBytes = BigIntUtils.changeToBytes(actualBigInt, order: Endian.little);

      // Assert
      Uint8List expectedBytes = base64Decode('0gKWSQ==');

      expect(actualBytes, expectedBytes);
    });

    test('Should [return padded Endian.little bytes] constructed from given BigInt and length', () {
      // Arrange
      BigInt actualBigInt = BigInt.parse('1234567890');

      // Act
      Uint8List actualBytes = BigIntUtils.changeToBytes(actualBigInt, length: 20, order: Endian.little);

      // Assert
      Uint8List expectedBytes = base64Decode('0gKWSQAAAAAAAAAAAAAAAAAAAAA=');

      expect(actualBytes, expectedBytes);
    });
  });

  group('Tests of BigIntUtils.calculateByteLength()', () {
    test('Should [return number] representing size (in bytes) needed to store given BigInt', () {
      // Arrange
      BigInt actualBigInt = BigInt.parse('111222333444555666777888999000');

      // Act
      int actualByteLength = BigIntUtils.calculateByteLength(actualBigInt);

      // Assert
      int expectedByteLength = 13;

      expect(actualByteLength, expectedByteLength);
    });
  });
}
