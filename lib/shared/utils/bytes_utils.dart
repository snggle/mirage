import 'dart:math';
import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';

class BytesUtils {
  static int convertBytesToInt(List<int> bytes, {Endian endian = Endian.big}) {
    int result = 0;

    for (int b in _iterateBytes(bytes, endian)) {
      result = (result << 8) | (b & 0xFF);
    }

    return result;
  }

  static BigInt convertBytesToBigInt(List<int> bytes, {Endian endian = Endian.big}) {
    BigInt result = BigInt.zero;

    for (int b in _iterateBytes(bytes, endian)) {
      result = (result << 8) | BigInt.from(b & 0xFF);
    }

    return result;
  }

  static Uint8List convertHexToBytes(String hex) {
    String normalized = _normalizeHex(hex);
    return HexCodec.decode(normalized);
  }

  static BigInt convertHexToBigInt(String hex) {
    String normalized = _normalizeHex(hex);
    return BigInt.parse(normalized, radix: 16);
  }

  static int convertHexToInt(String hex, {Endian endian = Endian.big}) {
    Uint8List bytes = convertHexToBytes(hex);
    return convertBytesToInt(bytes, endian: endian);
  }

  static Uint8List convertIntToBytes(int intToConvert, int length) {
    Uint8List bytes = Uint8List(length);

    for (int i = length - 1; i >= 0; i--) {
      bytes[i] = (intToConvert >> (8 * (length - 1 - i))) & 0xFF;
    }

    return bytes;
  }

  static String convertBytesToHex(Uint8List bytes) {
    return bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static List<int> generateRandomBytes(int count) {
    Random random = Random();
    List<int> randomIntegers = List<int>.generate(count, (_) => random.nextInt(256));
    return randomIntegers;
  }

  static Uint8List mergeBytes(List<List<int>> bytesLists) {
    return Uint8List.fromList(bytesLists.expand((List<int> list) => list).toList());
  }

  static Iterable<int> _iterateBytes(List<int> bytes, Endian endian) sync* {
    if (endian == Endian.little) {
      for (int i = bytes.length - 1; i >= 0; i--) {
        yield bytes[i];
      }
    } else {
      for (int i = 0; i < bytes.length; i++) {
        yield bytes[i];
      }
    }
  }

  static String _normalizeHex(String hex) {
    return hex.startsWith('0x') ? hex.substring(2) : hex;
  }
}
