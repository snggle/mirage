import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/shared/utils/bytes_utils.dart' as mirage;

import 'wallet.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  String cborInput = '81851a8000002c1a8000003c1a800000000000';

  List<int> payloadBytes = mirage.BytesUtils.convertHexToBytes(cborInput);
  Stream<List<int>> byteStream = Stream<List<int>>.fromIterable(<List<int>>[payloadBytes]);
  CborValue inputCborValue = await byteStream.transform(cbor.decoder).single;

  CborList cborList = inputCborValue as CborList;

  CborList cborNumericDerivationPath = cborList[0] as CborList;

  List<int> numericDerivationPath = <int>[];
  for (int i = 0; i < cborNumericDerivationPath.length; i++) {
    CborSmallInt index = cborNumericDerivationPath[i] as CborSmallInt;
    numericDerivationPath.add(index.value);
  }

  String derivationPath = _convertNumericDPToString(numericDerivationPath);
  String parentDerivationPath = _getParentDerivationPath(derivationPath);

  LegacyHDWallet wallet = await _getWallet(derivationPath);
  LegacyHDWallet parentWallet = await _getWallet(parentDerivationPath);

  CborValue outputCborValue = CborValue(<Object>[
    _getDerivationPathDepth(derivationPath),
    parentWallet.privateKey.metadata.fingerprint.toInt(),
    wallet.privateKey.metadata.chainCode,
    wallet.publicKey.bytes,
    _getXPub(wallet),
  ]);

  print('depth: ${_getDerivationPathDepth(derivationPath)}');
  print('fingerprint: ${parentWallet.privateKey.metadata.fingerprint.toInt()}');
  print('chainCode: ${wallet.privateKey.metadata.chainCode}');
  print('publicKey: ${wallet.publicKey.bytes}');
  print('xpub: ${_getXPub(wallet)}');
  print('');
  print('cbor: ${mirage.BytesUtils.convertBytesToHex(cbor.encode(outputCborValue))}');
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
  Uint8List chainCode = wallet.privateKey.metadata.chainCode;
  Uint8List parentFp = BigIntUtils.changeToBytes(wallet.privateKey.metadata.parentFingerprint);

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
