import 'package:codec_utils/codec_utils.dart';
import 'package:cryptography_utils/cryptography_utils.dart';

class CborUtils {
  static String getXPub(CborCryptoHDKey cborCryptoHDKey) {
    List<CborPathComponent> cborPathComponents = cborCryptoHDKey.origin!.components;
    CborPathComponent lastCborPathComponent = cborPathComponents[cborPathComponents.length - 1];

    Secp256k1PublicKey secp256k1PublicKey = Secp256k1PublicKey.fromCompressedBytes(
      cborCryptoHDKey.keyData,
      metadata: Bip32KeyMetadata.fromCompressedPublicKey(
        depth: cborPathComponents.length,
        compressedPublicKey: cborCryptoHDKey.keyData,
        parentFingerprint: BigInt.from(cborCryptoHDKey.parentFingerprint!),
        chainCode: cborCryptoHDKey.chainCode,
        shiftedIndex: LegacyDerivationPathElement(
          hardenedBool: lastCborPathComponent.hardened,
          rawIndex: lastCborPathComponent.index,
        ).shiftedIndex,
      ),
    );

    return secp256k1PublicKey.getExtendedPublicKey();
  }

  static List<CborPathComponent> convertToPathComponents(List<int> derivationPath) {
    LegacyDerivationPath legacyDerivationPath = LegacyDerivationPath.fromShiftedIndexes(derivationPath);
    return legacyDerivationPath.pathElements.map((LegacyDerivationPathElement pathElement) {
      return CborPathComponent(index: pathElement.rawIndex, hardened: pathElement.isHardened);
    }).toList();
  }

  static List<CborPathComponent> pathToCbor(String path) {
    final List<int> indices = _parseBip32PathToUint32(path);
    return convertToPathComponents(indices);
  }

  /// Parses BIP32 path like: "m/44'/60'/0'" or "44'/60'/0'/0/0".
  /// Returns a list of uint32 indices, where hardened has 0x80000000 set.
  static List<int> _parseBip32PathToUint32(String path) {
    final String p = path.trim();

    if (p.isEmpty) {
      throw const FormatException('Empty derivation path');
    }

    // allow optional leading "m/" or "M/"
    final String normalized = (p.startsWith('m/') || p.startsWith('M/')) ? p.substring(2) : p;

    if (normalized.isEmpty) {
      // path == "m" or "m/"
      return <int>[];
    }

    final List<String> parts = normalized.split('/');
    final List<int> out = <int>[];

    for (final String rawPart in parts) {
      final String part = rawPart.trim();
      if (part.isEmpty) {
        throw FormatException('Invalid derivation path segment: "$rawPart" in "$path"');
      }

      final bool hardened = part.endsWith("'") || part.endsWith('h') || part.endsWith('H');
      final String numberStr = hardened ? part.substring(0, part.length - 1) : part;

      if (numberStr.isEmpty) {
        throw FormatException('Invalid derivation path segment: "$rawPart" in "$path"');
      }

      final int? index = int.tryParse(numberStr);
      if (index == null) {
        throw FormatException('Invalid derivation index: "$rawPart" in "$path"');
      }
      if (index < 0) {
        throw FormatException('Derivation index must be >= 0: "$rawPart" in "$path"');
      }
      if (index > 0x7fffffff) {
        // because hardened uses the highest bit
        throw FormatException('Derivation index too large (max 2^31-1): "$rawPart" in "$path"');
      }

      final int value = hardened ? (index | 0x80000000) : index;
      out.add(value);
    }

    return out;
  }

}
