import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';

void main() {
  group('Tests of BytesUtils.convertBytesToBigInt()', () {
    test('Should [return BigInt] calculated from List<int>', () {
      // Arrange
      List<int> actualInputList = <int>[5, 10, 15];

      // Act
      BigInt actualBigInt = BytesUtils.convertBytesToBigInt(actualInputList);

      // Assert
      BigInt expectedBigInt = BigInt.from(330255);

      expect(actualBigInt, expectedBigInt);
    });
  });

  group('Tests of BytesUtils.convertBytesToHex()', () {
    test('Should [return hex bytes] calculated from BYTES', () {
      // Arrange
      Uint8List actualBytesInput = Uint8List.fromList(<int>[215, 21, 5, 90]);

      // Act
      String actualHex = BytesUtils.convertBytesToHex(actualBytesInput);

      // Assert
      String expectedHex = 'd715055a';

      expect(actualHex, expectedHex);
    });
  });

  group('Tests of BytesUtils.convertHexToInt()', () {
    test('Should [return int] calculated from HEX', () {
      // Arrange
      String actualHexInput = '1a2b3c';

      // Act
      int actualInt = BytesUtils.convertHexToInt(actualHexInput);

      // Assert
      int expectedInt = 1715004;

      expect(actualInt, expectedInt);
    });
  });

  group('Tests of BytesUtils.convertHexToBytes()', () {
    test('Should [return bytes] calculated from HEX', () {
      // Arrange
      String actualHexInput = '4d5e6f';

      // Act
      Uint8List actualBytes = BytesUtils.convertHexToBytes(actualHexInput);

      // Assert
      Uint8List expectedBytes = Uint8List.fromList(<int>[77, 94, 111]);

      expect(actualBytes, expectedBytes);
    });
  });

  group('Tests of BytesUtils.convertBytesToInt()', () {
    test('Should [return int] calculated from Big Endian BYTES', () {
      // Arrange
      Uint8List actualBytesInput = Uint8List.fromList(<int>[0, 19]);

      // Act
      int actualInt = BytesUtils.convertBytesToInt(actualBytesInput, endian: Endian.big);

      // Assert
      int expectedInt = 19;

      expect(actualInt, expectedInt);
    });

    test('Should [return int] calculated from Little Endian BYTES', () {
      // Arrange
      Uint8List actualBytesInput = Uint8List.fromList(<int>[0, 19]);

      // Act
      int actualInt = BytesUtils.convertBytesToInt(actualBytesInput, endian: Endian.little);

      // Assert
      int expectedInt = 4864;

      expect(actualInt, expectedInt);
    });
  });

  group('Tests of BytesUtils.convertIntToBytes()', () {
    test('Should [return bytes] representing given int (length = 2)', () {
      // Arrange
      int actualIntToConvert = 452;
      int actualLength = 2;

      // Act
      Uint8List actualBytes = BytesUtils.convertIntToBytes(actualIntToConvert, actualLength);

      // Assert
      Uint8List expectedBytes = Uint8List.fromList(<int>[1, 196]);

      expect(actualBytes, expectedBytes);
    });

    test('Should [return bytes] representing given int (length = 4)', () {
      // Arrange
      int actualIntToConvert = 452;
      int actualLength = 4;

      // Act
      Uint8List actualBytes = BytesUtils.convertIntToBytes(actualIntToConvert, actualLength);

      // Assert
      Uint8List expectedBytes = Uint8List.fromList(<int>[0, 0, 1, 196]);

      expect(actualBytes, expectedBytes);
    });
  });

  group('Tests of BytesUtils.generateRandomBytes()', () {
    test('Should [return 5 random bytes] given (count = 5)', () {
      // Arrange
      int actualCount = 5;

      // Act
      List<int> actualRandomBytes = BytesUtils.generateRandomBytes(actualCount);
      int actualLength = actualRandomBytes.length;

      // Assert
      int expectedLength = 5;

      expect(actualLength, expectedLength);
    });

    test('Should [return 32 random bytes] given (count = 32)', () {
      // Arrange
      int actualCount = 32;

      // Act
      List<int> actualRandomBytes = BytesUtils.generateRandomBytes(actualCount);
      int actualLength = actualRandomBytes.length;

      // Assert
      int expectedLength = 32;

      expect(actualLength, expectedLength);
    });
  });

  group('Tests of BytesUtils.mergeBytes()', () {
    test('Should [return merged Uint8List] from multiple Uint8Lists', () {
      // Arrange
      Uint8List actualBytesA = Uint8List.fromList(<int>[1, 2, 3, 4]);
      Uint8List actualBytesB = Uint8List.fromList(<int>[5, 6, 7, 8]);
      Uint8List actualBytesC = Uint8List.fromList(<int>[9, 10, 11, 12]);

      List<Uint8List> actualBytesToMerge = <Uint8List>[actualBytesA, actualBytesB, actualBytesC];

      // Act
      Uint8List actualMergedBytes = BytesUtils.mergeBytes(actualBytesToMerge);

      // Assert
      Uint8List expectedMergedBytes = Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);

      expect(actualMergedBytes, expectedMergedBytes);
    });
  });

  // TODO(Marcin): delete this method after prompt data input is replaced with Audio Protocol implementation
  group('Tests of BytesUtils.parseStringToList()', () {
    test('Should [return List<int>] given String input', () {
      // Arrange
      String actualString = '[2, 8, 500, 400, 17]';

      // Act
      List<int> actualList = BytesUtils.parseStringToList(actualString);

      // Assert
      List<int> expectedList = <int>[2, 8, 500, 400, 17];

      expect(actualList, expectedList);
    });
  });
}
