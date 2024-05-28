import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:dart_web3gas/web3dart/src/utils/rlp.dart' as rlp;
import 'package:mirage/config/wallet.dart';
import 'package:mirage/protobuf/compiled/messages-bitcoin.pb.dart';
import 'package:mirage/protobuf/compiled/messages-common.pb.dart';
import 'package:mirage/protobuf/compiled/messages-ethereum.pb.dart';
import 'package:mirage/protobuf/compiled/messages-management.pb.dart';
import 'package:mirage/shared/utils/byte_operations_utils.dart';

// ignore_for_file: avoid_print
class ProtobufResponses {
  static Future<PublicKey> publicKey(GetPublicKey getPublicKey) async {
    String derivationPath = _convertNumericDPToString(getPublicKey.addressN);
    String parentDerivationPath = _getParentDerivationPath(derivationPath);

    LegacyHDWallet wallet = await _getWallet(derivationPath);
    LegacyHDWallet parentWallet = await _getWallet(parentDerivationPath);

    return PublicKey(
      node: HDNodeType(
        depth: _getDerivationPathDepth(derivationPath),
        fingerprint: parentWallet.privateKey.metadata.fingerprint.toInt(),
        childNum: 0,
        // @formatter:off
        chainCode: wallet.privateKey.metadata.chainCode,
        publicKey: wallet.publicKey.bytes,
        // @formatter:on
      ),
      xpub: _getXPub(wallet),
    );
  }

  static Features featuresRandomSession = Features(
    vendor: 'trezor.io',
    majorVersion: 2,
    minorVersion: 7,
    patchVersion: 1,
    deviceId: '355C817510C0EABF2F147145',
    pinProtection: true,
    passphraseProtection: true,
    language: 'en-US',
    label: 'My Trezor',
    initialized: true,
    revision: <int>[199, 131, 44, 57, 171, 60, 42, 156, 70, 84, 76, 87, 209, 168, 152, 5, 131, 96, 159, 71],
    unlocked: true,
    needsBackup: false,
    flags: 0,
    model: 'T',
    fwVendor: 'EMULATOR',
    unfinishedBackup: false,
    noBackup: false,
    recoveryMode: false,
    capabilities: <Features_Capability>[
      Features_Capability.Capability_Bitcoin,
      Features_Capability.Capability_Bitcoin_like,
      Features_Capability.Capability_Binance,
      Features_Capability.Capability_Cardano,
      Features_Capability.Capability_Crypto,
      Features_Capability.Capability_Ethereum,
      Features_Capability.Capability_Monero,
      Features_Capability.Capability_Ripple,
      Features_Capability.Capability_Stellar,
      Features_Capability.Capability_Tezos,
      Features_Capability.Capability_U2F,
      Features_Capability.Capability_Shamir,
      Features_Capability.Capability_ShamirGroups,
      Features_Capability.Capability_PassphraseEntry,
      Features_Capability.Capability_Solana,
      Features_Capability.Capability_Translations,
      Features_Capability.Capability_NEM,
      Features_Capability.Capability_EOS,
    ],
    backupType: BackupType.Bip39,
    sdCardPresent: true,
    sdProtection: false,
    wipeCodeProtection: false,
    // @formatter:off
    sessionId: _generateRandomIntegers(32),
    // @formatter:on
    passphraseAlwaysOnDevice: false,
    safetyChecks: SafetyCheckLevel.Strict,
    autoLockDelayMs: 600000,
    displayRotation: 0,
    experimentalFeatures: false,
    busy: false,
    homescreenFormat: HomescreenFormat.Jpeg,
    hidePassphraseFromHost: false,
    internalModel: 'T2T1',
    homescreenWidth: 240,
    homescreenHeight: 240,
    languageVersionMatches: true,
  );

  static Features featuresNoSession = Features(
    vendor: 'trezor.io',
    majorVersion: 2,
    minorVersion: 7,
    patchVersion: 1,
    deviceId: '355C817510C0EABF2F147145',
    pinProtection: true,
    passphraseProtection: true,
    language: 'en-US',
    label: 'My Trezor',
    initialized: true,
    revision: <int>[199, 131, 44, 57, 171, 60, 42, 156, 70, 84, 76, 87, 209, 168, 152, 5, 131, 96, 159, 71],
    unlocked: true,
    needsBackup: false,
    flags: 0,
    model: 'T',
    fwVendor: 'EMULATOR',
    unfinishedBackup: false,
    noBackup: false,
    recoveryMode: false,
    capabilities: <Features_Capability>[
      Features_Capability.Capability_Bitcoin,
      Features_Capability.Capability_Bitcoin_like,
      Features_Capability.Capability_Binance,
      Features_Capability.Capability_Cardano,
      Features_Capability.Capability_Crypto,
      Features_Capability.Capability_Ethereum,
      Features_Capability.Capability_Monero,
      Features_Capability.Capability_Ripple,
      Features_Capability.Capability_Stellar,
      Features_Capability.Capability_Tezos,
      Features_Capability.Capability_U2F,
      Features_Capability.Capability_Shamir,
      Features_Capability.Capability_ShamirGroups,
      Features_Capability.Capability_PassphraseEntry,
      Features_Capability.Capability_Solana,
      Features_Capability.Capability_Translations,
      Features_Capability.Capability_NEM,
      Features_Capability.Capability_EOS,
    ],
    backupType: BackupType.Bip39,
    sdCardPresent: true,
    sdProtection: false,
    wipeCodeProtection: false,
    passphraseAlwaysOnDevice: false,
    safetyChecks: SafetyCheckLevel.Strict,
    autoLockDelayMs: 600000,
    displayRotation: 0,
    experimentalFeatures: false,
    busy: false,
    homescreenFormat: HomescreenFormat.Jpeg,
    hidePassphraseFromHost: false,
    internalModel: 'T2T1',
    homescreenWidth: 240,
    homescreenHeight: 240,
    languageVersionMatches: true,
  );

  static Address address = Address(
    address: '',
  );

  static PassphraseRequest passphraseRequest = PassphraseRequest();

  static ButtonRequest buttonRequest1 = ButtonRequest(
    code: ButtonRequest_ButtonRequestType.ButtonRequest_UnknownDerivationPath,
  );

  static ButtonRequest buttonRequest2 = ButtonRequest(
    code: ButtonRequest_ButtonRequestType.ButtonRequest_Other,
  );

  static ButtonRequest buttonRequest3 = ButtonRequest(
    code: ButtonRequest_ButtonRequestType.ButtonRequest_SignTx,
  );

  static Future<EthereumTxRequest> ethereumTxRequest(EthereumSignTxEIP1559 ethereumSignTxEIP1559) async {
    List<int> signData = _getSignData(ethereumSignTxEIP1559);
    print('signData: $signData');

    List<int> numericDerivationPath = ethereumSignTxEIP1559.addressN;
    String derivationPath = _convertNumericDPToString(numericDerivationPath);

    LegacyHDWallet ethereumWallet = await _getWallet(derivationPath);

    EthereumSignature ethereumSignature = await _getSignature(signData, ethereumWallet);

    Uint8List signatureR = ByteOperationsUtils.convertBigIntToBytes(ethereumSignature.r);
    Uint8List signatureS = ByteOperationsUtils.convertBigIntToBytes(ethereumSignature.s);

    return EthereumTxRequest(
      signatureV: ethereumSignature.getV(eip155Bool: false),
      signatureR: signatureR,
      signatureS: signatureS,
    );
  }

  static Features featuresAssignSession(List<int> sessionId) {
    return Features(
      vendor: 'trezor.io',
      majorVersion: 2,
      minorVersion: 7,
      patchVersion: 1,
      deviceId: '355C817510C0EABF2F147145',
      pinProtection: true,
      passphraseProtection: true,
      language: 'en-US',
      label: 'My Trezor',
      initialized: true,
      revision: <int>[199, 131, 44, 57, 171, 60, 42, 156, 70, 84, 76, 87, 209, 168, 152, 5, 131, 96, 159, 71],
      unlocked: true,
      needsBackup: false,
      flags: 0,
      model: 'T',
      fwVendor: 'EMULATOR',
      unfinishedBackup: false,
      noBackup: false,
      recoveryMode: false,
      capabilities: <Features_Capability>[
        Features_Capability.Capability_Bitcoin,
        Features_Capability.Capability_Bitcoin_like,
        Features_Capability.Capability_Binance,
        Features_Capability.Capability_Cardano,
        Features_Capability.Capability_Crypto,
        Features_Capability.Capability_Ethereum,
        Features_Capability.Capability_Monero,
        Features_Capability.Capability_Ripple,
        Features_Capability.Capability_Stellar,
        Features_Capability.Capability_Tezos,
        Features_Capability.Capability_U2F,
        Features_Capability.Capability_Shamir,
        Features_Capability.Capability_ShamirGroups,
        Features_Capability.Capability_PassphraseEntry,
        Features_Capability.Capability_Solana,
        Features_Capability.Capability_Translations,
        Features_Capability.Capability_NEM,
        Features_Capability.Capability_EOS,
      ],
      backupType: BackupType.Bip39,
      sdCardPresent: true,
      sdProtection: false,
      wipeCodeProtection: false,
      // @formatter:off
      sessionId: sessionId,
      // @formatter:on
      passphraseAlwaysOnDevice: false,
      safetyChecks: SafetyCheckLevel.Strict,
      autoLockDelayMs: 600000,
      displayRotation: 0,
      experimentalFeatures: false,
      busy: false,
      homescreenFormat: HomescreenFormat.Jpeg,
      hidePassphraseFromHost: false,
      internalModel: 'T2T1',
      homescreenWidth: 240,
      homescreenHeight: 240,
      languageVersionMatches: true,
    );
  }

  static List<int> _getSignData(EthereumSignTxEIP1559 ethereumSignTxEIP1559) {
    int chainId = ethereumSignTxEIP1559.chainId.toInt();
    Uint8List nonce = Uint8List.fromList(ethereumSignTxEIP1559.nonce);
    Uint8List maxPriorityFeePerGas = Uint8List.fromList(ethereumSignTxEIP1559.maxPriorityFee);
    Uint8List maxFeePerGas = Uint8List.fromList(ethereumSignTxEIP1559.maxGasFee);
    Uint8List gasLimit = Uint8List.fromList(ethereumSignTxEIP1559.gasLimit);
    Uint8List to = Uint8List.fromList(ByteOperationsUtils.convertHexStringToDecimalBytes(ethereumSignTxEIP1559.to));
    Uint8List value = Uint8List.fromList(ethereumSignTxEIP1559.value);
    int length = nonce.length + gasLimit.length + to.length + value.length + 3 + maxFeePerGas.length + maxPriorityFeePerGas.length + 192 + 8;

    List<int> encodedType = rlp.encode(0x2);
    List<int> encodedLength = <int>[length];
    List<int> encodedChainId = rlp.encode(chainId);
    List<int> encodedNonce = rlp.encode(nonce);
    List<int> encodedMaxPriorityFeePerGas = rlp.encode(maxPriorityFeePerGas);
    List<int> encodedMaxFeePerGas = rlp.encode(maxFeePerGas);
    List<int> encodedGasLimit = rlp.encode(gasLimit);
    List<int> encodedTo = rlp.encode(to);
    List<int> encodedValue = rlp.encode(value);
    List<int> encodedData = rlp.encode('');
    List<int> encodedAccessList = rlp.encode(<dynamic>[]);

    List<int> signData = List<int>.from(<List<int>>[])
      ..addAll(encodedType)
      ..addAll(encodedLength)
      ..addAll(encodedChainId)
      ..addAll(encodedNonce)
      ..addAll(encodedMaxPriorityFeePerGas)
      ..addAll(encodedMaxFeePerGas)
      ..addAll(encodedGasLimit)
      ..addAll(encodedTo)
      ..addAll(encodedValue)
      ..addAll(encodedData)
      ..addAll(encodedAccessList);

    return signData;
  }

  static String _convertNumericDPToString(List<int> numericDerivationPath) {
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

  static Future<EthereumSignature> _getSignature(List<int> signData, LegacyHDWallet wallet) async {
    ECPrivateKey ecPrivateKey = ECPrivateKey.fromBytes(wallet.privateKey.bytes, CurvePoints.generatorSecp256k1);

    EthereumSigner ethereumSigner = EthereumSigner(ecPrivateKey);
    EthereumSignature ethereumSignature = ethereumSigner.sign(Uint8List.fromList(signData));

    return ethereumSignature;
  }

  static int _getDerivationPathDepth(String derivationPath) {
    List<String> segments = derivationPath.split('/');

    return segments.length - 1;
  }

  static Future<LegacyHDWallet> _getWallet(String derivationPath) async {
    return LegacyHDWallet.fromMnemonic(
      mnemonic: Mnemonic.fromMnemonicPhrase(Wallet.mnemonicPhrase),
      walletConfig: Wallet.walletConfig,
      derivationPath: LegacyDerivationPath.parse(derivationPath),
    );
  }

  static String _getParentDerivationPath(String derivationPath) {
    List<String> segments = derivationPath.split('/');

    if (segments.length > 1) {
      segments.removeLast();
    }

    return segments.join('/');
  }

  static String _getXPub(LegacyHDWallet wallet) {
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

  static List<int> _generateRandomIntegers(int count) {
    Random random = Random();
    List<int> randomIntegers = List<int>.generate(count, (_) => random.nextInt(256));
    return randomIntegers;
  }
}
