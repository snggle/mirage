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
}
