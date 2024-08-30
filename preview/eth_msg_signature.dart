import 'dart:typed_data';

import 'package:cryptography_utils/cryptography_utils.dart';

import 'wallet.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  // input derivation path and message here
  List<int> numericDerivationPath = <int>[2147483692, 2147483708, 2147483648, 0, 1];
  List<int> message = <int>[87, 101, 108, 99, 111, 109, 101, 32, 116, 111, 32, 79, 112, 101, 110, 83, 101, 97, 33, 10, 10, 67, 108, 105, 99, 107, 32, 116, 111, 32, 115, 105, 103, 110, 32, 105, 110, 32, 97, 110, 100, 32, 97, 99, 99, 101, 112, 116, 32, 116, 104, 101, 32, 79, 112, 101, 110, 83, 101, 97, 32, 84, 101, 114, 109, 115, 32, 111, 102, 32, 83, 101, 114, 118, 105, 99, 101, 32, 40, 104, 116, 116, 112, 115, 58, 47, 47, 111, 112, 101, 110, 115, 101, 97, 46, 105, 111, 47, 116, 111, 115, 41, 32, 97, 110, 100, 32, 80, 114, 105, 118, 97, 99, 121, 32, 80, 111, 108, 105, 99, 121, 32, 40, 104, 116, 116, 112, 115, 58, 47, 47, 111, 112, 101, 110, 115, 101, 97, 46, 105, 111, 47, 112, 114, 105, 118, 97, 99, 121, 41, 46, 10, 10, 84, 104, 105, 115, 32, 114, 101, 113, 117, 101, 115, 116, 32, 119, 105, 108, 108, 32, 110, 111, 116, 32, 116, 114, 105, 103, 103, 101, 114, 32, 97, 32, 98, 108, 111, 99, 107, 99, 104, 97, 105, 110, 32, 116, 114, 97, 110, 115, 97, 99, 116, 105, 111, 110, 32, 111, 114, 32, 99, 111, 115, 116, 32, 97, 110, 121, 32, 103, 97, 115, 32, 102, 101, 101, 115, 46, 10, 10, 87, 97, 108, 108, 101, 116, 32, 97, 100, 100, 114, 101, 115, 115, 58, 10, 48, 120, 52, 55, 57, 98, 50, 57, 55, 48, 102, 48, 51, 102, 57, 48, 50, 49, 99, 102, 102, 48, 48, 98, 54, 101, 53, 56, 48, 55, 98, 97, 53, 52, 52, 101, 97, 51, 53, 49, 102, 56, 10, 10, 78, 111, 110, 99, 101, 58, 10, 97, 50, 53, 102, 52, 98, 57, 49, 45, 51, 56, 57, 49, 45, 52, 56, 102, 102, 45, 57, 54, 48, 53, 45, 98, 51, 48, 53, 100, 54, 99, 100, 48, 52, 56, 97];

  String derivationPath = _convertNumericDPToString(numericDerivationPath);
  LegacyHDWallet ethereumWallet = await _getWallet(derivationPath);
  EthereumSignature ethereumSignature = await _getSignature(message, ethereumWallet);

  Uint8List signatureV = Uint8List.fromList(<int>[ethereumSignature.v]);
  Uint8List signatureR = _convertBigIntToBytes(ethereumSignature.r);
  Uint8List signatureS = _convertBigIntToBytes(ethereumSignature.s);


  List<Uint8List> lists = <Uint8List>[signatureR, signatureS, signatureV];

  Uint8List signature = Uint8List.fromList(lists.expand((Uint8List list) => list).toList());

  EthereumAddressEncoder ethereumAddressEncoder = EthereumAddressEncoder(skipChecksumBool: false);

  String address = ethereumAddressEncoder.encodePublicKey(ethereumWallet.publicKey as Secp256k1PublicKey);

  print('signature: $signature');
  print('address: $address');
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
  EthereumSignature ethereumSignature = ethereumSigner.signPersonalMessage(Uint8List.fromList(signData));

  return ethereumSignature;
}

Future<LegacyHDWallet> _getWallet(String derivationPath) async {
  return LegacyHDWallet.fromMnemonic(
    mnemonic: Mnemonic.fromMnemonicPhrase(Wallet.mnemonicPhrase),
    walletConfig: Wallet.walletConfig,
    derivationPath: LegacyDerivationPath.parse(derivationPath),
  );
}
