import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/shared/utils/bytes_utils.dart' as mirage;

import 'wallet.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  String cborInput =
      '82851a8000002c1a8000003c1a80000000000059014e57656c636f6d6520746f204f70656e536561210a0a436c69636b20746f207369676e20696e20616e642061636365707420746865204f70656e536561205465726d73206f662053657276696365202868747470733a2f2f6f70656e7365612e696f2f746f732920616e64205072697661637920506f6c696379202868747470733a2f2f6f70656e7365612e696f2f70726976616379292e0a0a5468697320726571756573742077696c6c206e6f742074726967676572206120626c6f636b636861696e207472616e73616374696f6e206f7220636f737420616e792067617320666565732e0a0a57616c6c657420616464726573733a0a3078353362663061313837353438373361383130323632356438323235616636613135613433343233630a0a4e6f6e63653a0a32363861653162632d303634332d343336642d393766312d316163306539393035323537';

  List<int> payloadBytes = mirage.BytesUtils.convertHexToBytes(cborInput);
  Stream<List<int>> byteStream = Stream<List<int>>.fromIterable(<List<int>>[payloadBytes]);
  CborValue inputCborValue = await byteStream.transform(cbor.decoder).single;

  CborList cborList = inputCborValue as CborList;

  CborList cborNumericDerivationPath = cborList[0] as CborList;
  CborBytes cborMessage = cborList[1] as CborBytes;

  List<int> numericDerivationPath = <int>[];
  for (int i = 0; i < cborNumericDerivationPath.length; i++) {
    CborSmallInt index = cborNumericDerivationPath[i] as CborSmallInt;
    numericDerivationPath.add(index.value);
  }

  List<int> message = cborMessage.bytes;

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

  CborValue outputCborValue = CborValue(<Object>[
    address,
    signature,
  ]);

  print('address: $address');
  print('signature: $signature');
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
