import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-common.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-management.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/protobuf_msg_serializer.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

void main() {
  group('Tests of ProtobufMsgSerializer.deserialize()', () {
    test('Should [return GetFeatures] from the given bytes', () {
      // Arrange
      String actualBytes = '003700000000';

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgSerializer.deserialize(actualBytes);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = GetFeatures();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return GetAddress] from the given bytes', () {
      // Arrange
      String actualBytes = '001d0000002108ac80808008088180808008088080808008080008001207546573746e6574280000000000000000000000000000000000000000000000';

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgSerializer.deserialize(actualBytes);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = GetAddress(
        addressN: <int>[2147483692, 2147483649, 2147483648, 0, 0],
        coinName: 'Testnet',
        scriptType: InputScriptType.SPENDADDRESS,
      );

      expect(actualProtobufMsg, expectedProtobufMsg);
    });
  });

  group('Tests of ProtobufMsgSerializer.serialize()', () {
    test('Should [return bytes] from given message type: PassphraseRequest', () {
      // Arrange
      PassphraseRequest actualPassphraseRequest = PassphraseRequest();

      // Act
      String actualBytes = ProtobufMsgSerializer.serialize(actualPassphraseRequest);

      // Assert
      String expectedBytes = '002900000000';

      expect(actualBytes, expectedBytes);
    });

    test('Should [return bytes] from given message type: Features', () {
      // Arrange
      Features actualFeatures = Features(
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

      // Act
      String actualBytes = ProtobufMsgSerializer.serialize(actualFeatures);

      // Assert
      String expectedBytes =
          '0011000000e80a097472657a6f722e696f1002180720013218333535433831373531304330454142463246313437313435380140014a05656e2d555352094d79205472657a6f7260016a14c7832c39ab3c2a9c46544c57d1a8980583609f47800101980100a00100aa010154ca0108454d554c41544f52d80100e00100e80100f00101f00102f00103f00104f00105f00107f00109f0010bf0010cf0010df0010ef0010ff00110f00111f00112f00113f0010af00106f80100800201880200900200a00200a80200b002c0cf24b80200c00200c80200d00202d80200e2020454325431f802f0018003f001900301';

      expect(actualBytes, expectedBytes);
    });
  });
}
