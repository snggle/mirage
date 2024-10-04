import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/shared/utils/big_int_utils.dart';


import 'wallet.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  String cborInput = 'a10188182cf5183cf500f500f4';

  // Get UR Input
  Uint8List payloadBytes = HexCodec.decode(cborInput);
  CborCryptoKeypath cborCryptoKeypath = CborCryptoKeypath.fromSerializedCbor(payloadBytes);

  // Calculate
  String derivationPath = _convertToDerivationPath(cborCryptoKeypath.components);
  String parentDerivationPath = _getParentDerivationPath(derivationPath);

  LegacyHDWallet wallet = await _getWallet(derivationPath);
  LegacyHDWallet parentWallet = await _getWallet(parentDerivationPath);

  // Create UR Output
  CborCryptoHDKey cborCryptoHDKey = CborCryptoHDKey(
    isMaster: true,
    isPrivate: false,
    keyData: wallet.privateKey.publicKey.compressed,
    chainCode: wallet.privateKey.metadata.chainCode,
    origin: cborCryptoKeypath,
    parentFingerprint: parentWallet.privateKey.metadata.fingerprint.toInt(),
  );
  Uint8List outputSerializedCbor = cborCryptoHDKey.toSerializedCbor(includeTagBool: false);

  // Display
  print('depth: ${cborCryptoHDKey.origin!.components.length}');
  print('fingerprint: ${cborCryptoHDKey.parentFingerprint!}');
  print('chainCode: ${cborCryptoHDKey.chainCode!}');
  print('publicKey: ${cborCryptoHDKey.keyData}');
  print('xpub: ${_getXPub(cborCryptoHDKey)}');
  print('');
  print('cbor: ${HexCodec.encode(outputSerializedCbor)}');
}

String _getParentDerivationPath(String derivationPath) {
  List<String> segments = derivationPath.split('/');

  if (segments.length > 1) {
    segments.removeLast();
  }

  return segments.join('/');
}

String _getXPub(CborCryptoHDKey cborCryptoHDKey) {
  List<CborPathComponent> pathComponents = cborCryptoHDKey.origin!.components;

  Uint8List compressedKey = cborCryptoHDKey.keyData;
  Uint8List chainCode = cborCryptoHDKey.chainCode!;
  Uint8List parentFp = BigIntUtils.changeToBytes(BigInt.from(cborCryptoHDKey.parentFingerprint!));

  List<int> pubNetVer = <int>[0x04, 0x88, 0xb2, 0x1e];

  List<int> serKey = List<int>.from(<int>[
    ...pubNetVer,
    ...BigIntUtils.changeToBytes(BigInt.from(pathComponents.length)),
    ...parentFp,
    ..._pathElementToBytes(pathComponents[pathComponents.length - 1]),
    ...chainCode,
    ...compressedKey
  ]);

  return Base58Codec.encodeWithChecksum(Uint8List.fromList(serKey));
}

Future<LegacyHDWallet> _getWallet(String derivationPath) async {
  return LegacyHDWallet.fromMnemonic(
    mnemonic: Mnemonic.fromMnemonicPhrase(Wallet.mnemonicPhrase),
    walletConfig: Wallet.walletConfig,
    derivationPath: LegacyDerivationPath.parse(derivationPath),
  );
}

String _convertToDerivationPath(List<CborPathComponent> cborPathComponents) {
  String path = cborPathComponents.map((CborPathComponent component) {
    String formattedIndex = component.hardened ? "${component.index}'" : '${component.index}';
    return formattedIndex;
  }).join('/');

  return 'm/$path';
}

Uint8List _pathElementToBytes(CborPathComponent cborPathComponent, [Endian endian = Endian.big]) {
  return Uint8List(4)..buffer.asByteData().setInt32(0, _getShiftedIndex(cborPathComponent), endian);
}

int _getShiftedIndex(CborPathComponent pathComponent) {
  if (pathComponent.hardened) {
    return pathComponent.index | (1 << 31);
  } else {
    return pathComponent.index & ~(1 << 31);
  }
}
