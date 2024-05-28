import 'dart:typed_data';

class BytesUtils {
  static int convertHexToInt(String hex) {
    Uint8List bytes = convertHexToBytes(hex);
    return convertBytesToInt(bytes);
  }

  static String convertBytesToHex(Uint8List bytes) {
    return bytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  static int convertBytesToInt(Uint8List bytes) {
    int result = 0;
    for (int i = 0; i < bytes.lengthInBytes; i++) {
      result += bytes[i] << (8 * (bytes.lengthInBytes - 1 - i));
    }
    return result;
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

  static Uint8List convertIntToBytes(int intToConvert, int length) {
    Uint8List bytes = Uint8List(length);

    for (int i = length - 1; i >= 0; i--) {
      bytes[i] = (intToConvert >> (8 * (length - 1 - i))) & 0xFF;
    }

    return bytes;
  }

  static Uint8List mergeUint8Lists(List<Uint8List> lists) {
    return Uint8List.fromList(lists.expand((Uint8List list) => list).toList());
  }
}
