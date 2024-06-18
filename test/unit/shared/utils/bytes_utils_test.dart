import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';

void main() {
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

  group('Tests of BytesUtils.convertBytesToInt()', () {
    test('Should [return int] calculated from BYTES', () {
      // Arrange
      Uint8List actualBytesInput = Uint8List.fromList(<int>[215, 21, 5, 90]);

      // Act
      int actualInt = BytesUtils.convertBytesToInt(actualBytesInput);

      // Assert
      int expectedInt = 3608479066;

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

  group('Tests of BytesUtils.mergeUint8Lists()', () {
    test('Should [return merged Uint8List] from multiple Uint8Lists', () {
      // Arrange
      Uint8List actualUint8listA = Uint8List.fromList(<int>[1, 2, 3, 4]);
      Uint8List actualUint8listB = Uint8List.fromList(<int>[5, 6, 7, 8]);
      Uint8List actualUint8listC = Uint8List.fromList(<int>[9, 10, 11, 12]);

      List<Uint8List> actualUint8listsToMerge = <Uint8List>[actualUint8listA, actualUint8listB, actualUint8listC];

      // Act
      Uint8List actualMergedUint8List = BytesUtils.mergeUint8Lists(actualUint8listsToMerge);

      // Assert
      Uint8List expectedMergedUint8List = Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);

      expect(actualMergedUint8List, expectedMergedUint8List);
    });
  });
}
