import 'dart:typed_data';

import 'package:cryptography_utils/cryptography_utils.dart';

import 'wallet.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  // input derivation path and message here
  List<int> numericDerivationPath = <int>[2147483692, 2147483708, 2147483648, 0, 0];
  List<int> message = <int>[112, 97, 115, 115, 112, 111, 114, 116, 46, 103, 105, 116, 99, 111, 105, 110, 46, 99, 111, 32, 119, 97, 110, 116, 115, 32, 121, 111, 117, 32, 116, 111, 32, 115, 105, 103, 110, 32, 105, 110, 32, 119, 105, 116, 104, 32, 121, 111, 117, 114, 32, 69, 116, 104, 101, 114, 101, 117, 109, 32, 97, 99, 99, 111, 117, 110, 116, 58, 10, 48, 120, 53, 51, 98, 102, 48, 97, 49, 56, 55, 53, 52, 56, 55, 51, 97, 56, 49, 48, 50, 54, 50, 53, 100, 56, 50, 50, 53, 97, 102, 54, 97, 49, 53, 97, 52, 51, 52, 50, 51, 99, 10, 10, 71, 105, 118, 101, 32, 116, 104, 105, 115, 32, 97, 112, 112, 108, 105, 99, 97, 116, 105, 111, 110, 32, 97, 99, 99, 101, 115, 115, 32, 116, 111, 32, 115, 111, 109, 101, 32, 111, 102, 32, 121, 111, 117, 114, 32, 100, 97, 116, 97, 32, 111, 110, 32, 67, 101, 114, 97, 109, 105, 99, 10, 10, 85, 82, 73, 58, 32, 100, 105, 100, 58, 107, 101, 121, 58, 122, 68, 110, 97, 101, 117, 71, 117, 77, 84, 105, 72, 122, 90, 67, 75, 121, 67, 116, 86, 120, 116, 87, 53, 98, 102, 116, 70, 121, 53, 104, 69, 68, 106, 84, 75, 67, 121, 75, 109, 89, 110, 87, 111, 78, 119, 111, 114, 88, 10, 86, 101, 114, 115, 105, 111, 110, 58, 32, 49, 10, 67, 104, 97, 105, 110, 32, 73, 68, 58, 32, 49, 10, 78, 111, 110, 99, 101, 58, 32, 116, 80, 104, 120, 51, 121, 87, 85, 71, 65, 10, 73, 115, 115, 117, 101, 100, 32, 65, 116, 58, 32, 50, 48, 50, 52, 45, 48, 55, 45, 48, 49, 84, 48, 57, 58, 49, 49, 58, 48, 53, 46, 52, 57, 50, 90, 10, 69, 120, 112, 105, 114, 97, 116, 105, 111, 110, 32, 84, 105, 109, 101, 58, 32, 50, 48, 50, 52, 45, 48, 55, 45, 48, 56, 84, 48, 57, 58, 49, 49, 58, 48, 53, 46, 52, 57, 50, 90, 10, 82, 101, 115, 111, 117, 114, 99, 101, 115, 58, 10, 45, 32, 99, 101, 114, 97, 109, 105, 99, 58, 47, 47, 42];

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
