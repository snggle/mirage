import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:cryptography_utils/cryptography_utils.dart';

import 'wallet.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  String cborInput =
      'd90191a601d825410102583302f183aa36a73e8459682f00845c4d5ab18252089453bf0a18754873a8102625d8225af6a15a43423c872386f26fc1000080c00301041a00aa36a705d90130a1018a182cf5183cf500f500f401f40654479b2970f03f9021cff00b6e5807ba544ea351f8';

  // Get CBOR Input
  Uint8List payloadBytes = HexCodec.decode(cborInput);
  print('BYTES');
  print(payloadBytes);
  CborEthSignRequest cborEthSignRequest = CborEthSignRequest.fromSerializedCbor(payloadBytes);

  // Calculate
  List<int> signData = cborEthSignRequest.signData;
  String derivationPath = _convertToDerivationPath(cborEthSignRequest.derivationPath.components);
  LegacyHDWallet ethereumWallet = await _getWallet(derivationPath);
  EthereumSignature ethereumSignature = await _getSignature(signData, ethereumWallet);
  Uint8List signatureR = _convertBigIntToBytes(ethereumSignature.r);
  Uint8List signatureS = _convertBigIntToBytes(ethereumSignature.s);

  // Create CBOR Output
  CborEthSignature cborEthSignature = CborEthSignature(
    signature: ethereumSignature.bytes,
    origin: cborEthSignRequest.origin,
    requestId: cborEthSignRequest.requestId ?? Uint8List(0),
  );

  Uint8List outputSerializedCbor = cborEthSignature.toSerializedCbor(includeTagBool: true);

  // Display
  print('signatureR: $signatureR');
  print('signatureS: $signatureS');
  print('signatureV: ${ethereumSignature.v}');
  print('signature: ${ethereumSignature.bytes}');
  print('');
  print('cbor: ${HexCodec.encode(outputSerializedCbor)}');
}

Uint8List _convertBigIntToBytes(BigInt number) {
  int byteLength = (number.bitLength + 7) ~/ 8;

  Uint8List result = Uint8List(byteLength);

  for (int i = 0; i < byteLength; i++) {
    result[byteLength - i - 1] = (number >> (8 * i)).toUnsigned(8).toInt();
  }

  return result;
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

String _convertToDerivationPath(List<CborPathComponent> cborPathComponents) {
  String path = cborPathComponents.map((CborPathComponent component) {
    String formattedIndex = component.hardened ? "${component.index}'" : '${component.index}';
    return formattedIndex;
  }).join('/');

  return 'm/$path';
}
