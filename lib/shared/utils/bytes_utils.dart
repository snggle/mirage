import 'dart:math';
import 'dart:typed_data';

class BytesUtils {
  static BigInt convertBytesToBigInt(List<int> bytes, {Endian endian = Endian.big}) {
    return BigInt.from(convertBytesToInt(bytes, endian: endian));
  }

  static String convertBytesToHex(List<int> bytes) {
    return bytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  static int convertHexToInt(String hex, {Endian endian = Endian.big}) {
    Uint8List bytes = convertHexToBytes(hex);
    return convertBytesToInt(bytes, endian: endian);
  }

  static Uint8List convertHexToBytes(String hex) {
    if (hex.length % 2 != 0) {
      throw const FormatException('Invalid hexadecimal string length');
    }

    int length = hex.length ~/ 2;
    Uint8List result = Uint8List(length);

    for (int i = 0; i < length; i++) {
      String byte = hex.substring(i * 2, i * 2 + 2);
      result[i] = int.parse(byte, radix: 16);
    }

    return result;
  }

  static int convertBytesToInt(List<int> bytes, {Endian endian = Endian.big}) {
    switch (endian) {
      case Endian.little:
        return (bytes[1] << 8) + bytes[0];
      case Endian.big:
      default:
        int result = 0;
        for (int i = 0; i < bytes.length; i++) {
          result += bytes[i] << (8 * (bytes.length - 1 - i));
        }
        return result;
    }
  }

  static Uint8List convertIntToBytes(int intToConvert, int length) {
    Uint8List bytes = Uint8List(length);

    for (int i = length - 1; i >= 0; i--) {
      bytes[i] = (intToConvert >> (8 * (length - 1 - i))) & 0xFF;
    }

    return bytes;
  }

  static List<int> generateRandomBytes(int count) {
    Random random = Random();
    List<int> randomIntegers = List<int>.generate(count, (_) => random.nextInt(256));
    return randomIntegers;
  }

  static Uint8List mergeBytes(List<List<int>> bytesLists) {
    return Uint8List.fromList(bytesLists.expand((List<int> list) => list).toList());
  }

  // TODO(Marcin): delete this method after prompt data input is replaced with Audio Protocol implementation
  static List<int> parseStringToList(String input) {
    String clearInput = input.replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');
    return clearInput.split(',').map(int.parse).toList();
  }
}
