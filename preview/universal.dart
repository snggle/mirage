import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/shared/utils/big_int_utils.dart';

import 'wallet.dart';

// ignore_for_file: avoid_print
Future<void> main() async {
  String cborInput =
      'd90191a501d8254101025901666f70656e7365612e696f2077616e747320796f7520746f207369676e20696e207769746820796f7572206163636f756e743a0a3078343739623239373066303366393032316366463030423665353830374241353434454133353166380a0a436c69636b20746f207369676e20696e20616e642061636365707420746865204f70656e536561205465726d73206f662053657276696365202868747470733a2f2f6f70656e7365612e696f2f746f732920616e64205072697661637920506f6c696379202868747470733a2f2f6f70656e7365612e696f2f70726976616379292e0a0a5552493a2068747470733a2f2f6f70656e7365612e696f2f70726f66696c650a56657273696f6e3a20310a436861696e2049443a2031313135353131310a4e6f6e63653a20676673616c6e70306a376961636865686e346d68306e6f6866320a4973737565642041743a20323032352d30382d31385431323a33313a34322e3130355a030305d90130a1018a182cf5183cf500f500f401f40654479b2970f03f9021cff00b6e5807ba544ea351f8';

  // Get CBOR Input
  Uint8List payloadBytes = HexCodec.decode(cborInput);
  ACborTaggedObject? cborTaggedObject = ACborTaggedObject.fromSerializedCbor(payloadBytes);

  switch (cborTaggedObject) {
    case CborCryptoKeypath cborCryptoKeypath:
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
      Uint8List outputSerializedCbor = cborCryptoHDKey.toSerializedCbor(includeTagBool: true);

      // Display
      print('depth: ${cborCryptoHDKey.origin!.components.length}');
      print('fingerprint: ${cborCryptoHDKey.parentFingerprint!}');
      print('chainCode: ${cborCryptoHDKey.chainCode!}');
      print('publicKey: ${cborCryptoHDKey.keyData}');
      print('xpub: ${_getXPub(cborCryptoHDKey)}');
      print('');
      print('cbor: ${HexCodec.encode(outputSerializedCbor)}');

    case CborEthSignRequest cborEthSignRequest:
      // Calculate
      List<int> signData = cborEthSignRequest.signData;
      String derivationPath = _convertToDerivationPath(cborEthSignRequest.derivationPath.components);
      LegacyHDWallet ethereumWallet = await _getWallet(derivationPath);
      EthereumSignature ethereumSignature = await _getSignature(signData, ethereumWallet, cborEthSignRequest.dataType);
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
    default:
  }
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

Uint8List _convertBigIntToBytes(BigInt number) {
  int byteLength = (number.bitLength + 7) ~/ 8;

  Uint8List result = Uint8List(byteLength);

  for (int i = 0; i < byteLength; i++) {
    result[byteLength - i - 1] = (number >> (8 * i)).toUnsigned(8).toInt();
  }

  return result;
}

Future<EthereumSignature> _getSignature(List<int> signData, LegacyHDWallet wallet, CborEthSignDataType cborEthSignDataType) async {
  ECPrivateKey ecPrivateKey = ECPrivateKey.fromBytes(wallet.privateKey.bytes, CurvePoints.generatorSecp256k1);

  EthereumSigner ethereumSigner = EthereumSigner(ecPrivateKey);

  if (cborEthSignDataType == CborEthSignDataType.transactionData) {
    return ethereumSigner.sign(Uint8List.fromList(signData));
  } else {
    return ethereumSigner.signPersonalMessage(Uint8List.fromList(signData));
  }
}
