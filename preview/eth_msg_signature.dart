import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:cryptography_utils/cryptography_utils.dart';

import 'wallet.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  String cborInput =
      'a501d82541010259014e57656c636f6d6520746f204f70656e536561210a0a436c69636b20746f207369676e20696e20616e642061636365707420746865204f70656e536561205465726d73206f662053657276696365202868747470733a2f2f6f70656e7365612e696f2f746f732920616e64205072697661637920506f6c696379202868747470733a2f2f6f70656e7365612e696f2f70726976616379292e0a0a5468697320726571756573742077696c6c206e6f742074726967676572206120626c6f636b636861696e207472616e73616374696f6e206f7220636f737420616e792067617320666565732e0a0a57616c6c657420616464726573733a0a3078343739623239373066303366393032316366663030623665353830376261353434656133353166380a0a4e6f6e63653a0a66643661313033622d366539392d343337362d383966662d306662643663343139633831030305d90130a1018a182cf5183cf500f500f401f40654479b2970f03f9021cff00b6e5807ba544ea351f8';

  // Get UR Input
  Uint8List payloadBytes = HexCodec.decode(cborInput);
  CborEthSignRequest cborEthSignRequest = CborEthSignRequest.fromSerializedCbor(payloadBytes);

  // Calculate
  List<int> message = cborEthSignRequest.signData;
  String derivationPath = _convertToDerivationPath(cborEthSignRequest.derivationPath.components);
  LegacyHDWallet ethereumWallet = await _getWallet(derivationPath);
  EthereumSignature ethereumSignature = await _getSignature(message, ethereumWallet);

  Uint8List signatureV = Uint8List.fromList(<int>[ethereumSignature.v]);
  Uint8List signatureR = _convertBigIntToBytes(ethereumSignature.r);
  Uint8List signatureS = _convertBigIntToBytes(ethereumSignature.s);

  List<Uint8List> lists = <Uint8List>[signatureR, signatureS, signatureV];
  Uint8List signature = Uint8List.fromList(lists.expand((Uint8List list) => list).toList());

  // Create UR Output
  CborEthSignature cborEthSignature = CborEthSignature(
    requestId: Uint8List.fromList(<int>[]),
    signature: signature,
  );
  Uint8List outputSerializedCbor = cborEthSignature.toSerializedCbor(includeTagBool: false);

  // Display
  print('signature: $signature');
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

String _convertToDerivationPath(List<CborPathComponent> cborPathComponents) {
  String path = cborPathComponents.map((CborPathComponent component) {
    String formattedIndex = component.hardened ? "${component.index}'" : '${component.index}';
    return formattedIndex;
  }).join('/');

  return 'm/$path';
}