import 'dart:typed_data';

import 'package:cryptography_utils/cryptography_utils.dart';

import 'wallet.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  // input derivation path here
  List<int> numericDerivationPath = <int>[2147483692, 2147483708, 2147483648, 0];

  String derivationPath = _convertNumericDPToString(numericDerivationPath);
  String parentDerivationPath = _getParentDerivationPath(derivationPath);

  LegacyHDWallet wallet = await _getWallet(derivationPath);
  LegacyHDWallet parentWallet = await _getWallet(parentDerivationPath);

  print('depth: ${_getDerivationPathDepth(derivationPath)}');
  print('fingerprint: ${parentWallet.privateKey.metadata.fingerprint.toInt()}');
  print('chainCode: ${wallet.privateKey.metadata.chainCode}');
  print('publicKey: ${wallet.publicKey.compressed}');
  print('xpub: ${_getXPub(wallet)}');
}

String _convertNumericDPToString(List<int> numericDerivationPath) {
  String derivationPath = 'm/';
  for (int i = 0; i < numericDerivationPath.length; i++) {
    if (i < numericDerivationPath.length - 1) {
      derivationPath += "${numericDerivationPath[i] >= 0x80000000 ? "${numericDerivationPath[i] - 0x80000000}'" : numericDerivationPath[i].toString()}/";
    } else {
      derivationPath += numericDerivationPath[i] >= 0x80000000 ? "${numericDerivationPath[i] - 0x80000000}'" : numericDerivationPath[i].toString();
    }
  }

  return derivationPath;
}

int _getDerivationPathDepth(String derivationPath) {
  List<String> segments = derivationPath.split('/');

  return segments.length - 1;
}

String _getParentDerivationPath(String derivationPath) {
  List<String> segments = derivationPath.split('/');

  if (segments.length > 1) {
    segments.removeLast();
  }

  return segments.join('/');
}

String _getXPub(LegacyHDWallet wallet) {
  LegacyDerivationPath legacyDerivationPath = wallet.derivationPath;

  Uint8List compressedKey = (wallet.publicKey as Secp256k1PublicKey).compressed;
  Uint8List chainCode = wallet.privateKey.metadata.chainCode!;
  Uint8List parentFp = BigIntUtils.changeToBytes(wallet.privateKey.metadata.parentFingerprint!);

  List<int> pubNetVer = <int>[0x04, 0x88, 0xb2, 0x1e];

  List<int> serKey = List<int>.from(<int>[
    ...pubNetVer,
    ...BigIntUtils.changeToBytes(BigInt.from(legacyDerivationPath.pathElements.length)),
    ...parentFp,
    ...legacyDerivationPath.pathElements[legacyDerivationPath.pathElements.length - 1].toBytes(),
    ...chainCode,
    ...compressedKey
  ]);

  return Base58Encoder.encodeWithChecksum(Uint8List.fromList(serKey));
}

Future<LegacyHDWallet> _getWallet(String derivationPath) async {
  return LegacyHDWallet.fromMnemonic(
    mnemonic: Mnemonic.fromMnemonicPhrase(Wallet.mnemonicPhrase),
    walletConfig: Wallet.walletConfig,
    derivationPath: LegacyDerivationPath.parse(derivationPath),
  );
}
