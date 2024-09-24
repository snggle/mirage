import 'dart:math';
import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';

class BytesUtils {
  static BigInt convertBytesToBigInt(List<int> bytes, {Endian endian = Endian.big}) {
    return BigInt.from(convertBytesToInt(bytes, endian: endian));
  }

  static int convertHexToInt(String hex, {Endian endian = Endian.big}) {
    Uint8List bytes = HexCodec.decode(hex);
    return convertBytesToInt(bytes, endian: endian);
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
}
