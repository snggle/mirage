import 'dart:typed_data';

import 'package:cryptography_utils/cryptography_utils.dart';

import 'wallet.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  // input derivation path and sign data here
  List<int> numericDerivationPath = <int>[2147483692, 2147483708, 2147483648, 0, 0];
  List<int> signData = <int>[2, 242, 131, 170, 54, 167, 33, 132, 89, 104, 47, 0, 133, 1, 22, 214, 92, 178, 130, 82, 8, 148, 71, 155, 41, 112, 240, 63, 144, 33, 207, 240, 11, 110, 88, 7, 186, 84, 78, 163, 81, 248, 135, 35, 134, 242, 111, 193, 0, 0, 128, 192];

  String derivationPath = _convertNumericDPToString(numericDerivationPath);
  LegacyHDWallet ethereumWallet = await _getWallet(derivationPath);
  EthereumSignature ethereumSignature = await _getSignature(signData, ethereumWallet);

  Uint8List signatureR = _convertBigIntToBytes(ethereumSignature.r);
  Uint8List signatureS = _convertBigIntToBytes(ethereumSignature.s);

  print('signatureV: ${ethereumSignature.v}');
  print('signatureR: $signatureR');
  print('signatureS: $signatureS');
}

Uint8List _convertBigIntToBytes(BigInt number) {
  int byteLength = (number.bitLength + 7) ~/ 8;

  Uint8List result = Uint8List(byteLength);

  for (int i = 0; i < byteLength; i++) {
    result[byteLength - i - 1] = (number >> (8 * i)).toUnsigned(8).toInt();
  }

  return result;
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

Future<EthereumSignature> _getSignature(List<int> signData, LegacyHDWallet wallet) async {
  ECPrivateKey ecPrivateKey = ECPrivateKey.fromBytes(wallet.privateKey.bytes, CurvePoints.generatorSecp256k1);

  EthereumSigner ethereumSigner = EthereumSigner(ecPrivateKey);
  EthereumSignature ethereumSignature = ethereumSigner.sign(Uint8List.fromList(signData));

  return ethereumSignature;
}

Future<LegacyHDWallet> _getWallet(String derivationPath) async {
  return LegacyHDWallet.fromMnemonic(
    mnemonic: Mnemonic.fromMnemonicPhrase(Wallet.mnemonicPhrase),
    walletConfig: Wallet.walletConfig,
    derivationPath: LegacyDerivationPath.parse(derivationPath),
  );
}