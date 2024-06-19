import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/shared/utils/bytes_utils.dart' as mirage;

import 'wallet.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  String cborInput = '82851a8000002c1a8000003c1a800000000000583402f283aa36a7368459682f0085084f3fc8eb8252089453bf0a18754873a8102625d8225af6a15a43423c872386f26fc1000080c0';

  List<int> payloadBytes = mirage.BytesUtils.convertHexToBytes(cborInput);
  Stream<List<int>> byteStream = Stream<List<int>>.fromIterable(<List<int>>[payloadBytes]);
  CborValue inputCborValue = await byteStream.transform(cbor.decoder).single;

  CborList cborList = inputCborValue as CborList;

  CborList cborNumericDerivationPath = cborList[0] as CborList;
  CborBytes cborSignData = cborList[1] as CborBytes;

  List<int> numericDerivationPath = <int>[];
  for (int i = 0; i < cborNumericDerivationPath.length; i++) {
    CborSmallInt index = cborNumericDerivationPath[i] as CborSmallInt;
    numericDerivationPath.add(index.value);
  }

  List<int> signData = cborSignData.bytes;

  String derivationPath = _convertNumericDPToString(numericDerivationPath);
  LegacyHDWallet ethereumWallet = await _getWallet(derivationPath);
  EthereumSignature ethereumSignature = await _getSignature(signData, ethereumWallet);

  Uint8List signatureR = _convertBigIntToBytes(ethereumSignature.r);
  Uint8List signatureS = _convertBigIntToBytes(ethereumSignature.s);

  CborValue outputCborValue = CborValue(<Object>[
    ethereumSignature.v,
    signatureR,
    signatureS,
  ]);

  print('signatureV: ${ethereumSignature.v}');
  print('signatureR: $signatureR');
  print('signatureS: $signatureS');
  print('');
  print('cbor: ${mirage.BytesUtils.convertBytesToHex(cbor.encode(outputCborValue))}');
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
