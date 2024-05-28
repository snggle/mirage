import 'dart:typed_data';

class ByteOperationsUtils {
  static int convertDecBytesToInt(Uint8List decBytes) {
    int result = 0;
    for (int i = 0; i < decBytes.lengthInBytes; i++) {
      result += decBytes[i] << (8 * (decBytes.lengthInBytes - 1 - i));
    }
    return result;
  }

  static Uint8List convertIntToBigEndianBytes(int intToConvert, int bytesNumber) {
    Uint8List bytes = Uint8List(bytesNumber);

    for (int i = bytesNumber - 1; i >= 0; i--) {
      bytes[i] = (intToConvert >> (8 * (bytesNumber - 1 - i))) & 0xFF;
    }

    return bytes;
  }

  static Uint8List convertHexStringToBytes(String hexInput) {
    if (hexInput.length % 2 != 0) {
      throw const FormatException('Invalid hexadecimal string length');
    }

    final int length = hexInput.length ~/ 2;
    final Uint8List result = Uint8List(length);

    for (int i = 0; i < length; i++) {
      final String byte = hexInput.substring(i * 2, i * 2 + 2);
      result[i] = int.parse(byte, radix: 16);
    }

    return result;
  }

  static Uint8List convertBigIntToBytes(BigInt number) {
    int byteLength = (number.bitLength + 7) ~/ 8;

    Uint8List result = Uint8List(byteLength);

    for (int i = 0; i < byteLength; i++) {
      result[byteLength - i - 1] = (number >> (8 * i)).toUnsigned(8).toInt();
    }

    return result;
  }

  static List<int> convertHexStringToDecimalBytes(String hexString) {
    List<int> decimalList = <int>[];
    for (int i = 0; i < hexString.length; i += 2) {
      String hexPair = hexString.substring(i, i + 2);
      int decimalValue = int.parse(hexPair, radix: 16);
      decimalList.add(decimalValue);
    }
    return decimalList;
  }

  static int convertHexStringToInt(String hexInput) {
    Uint8List bytes = convertHexStringToBytes(hexInput);
    return convertDecBytesToInt(bytes);
  }

  static Uint8List mergeUint8Lists(List<Uint8List> lists) {
    int totalLength = lists.fold(0, (int sum, Uint8List list) => sum + list.length);
    Uint8List mergedList = Uint8List(totalLength);
    int offset = 0;
    for (Uint8List list in lists) {
      mergedList.setAll(offset, list);
      offset += list.length;
    }
    return mergedList;
  }
}
