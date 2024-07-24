import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-management.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorPropertiesResponse extends ATrezorOutboundResponse {
  final bool busy;
  final bool experimentalFeatures;
  final bool hidePassphraseFromHost;
  final bool initialized;
  final bool languageVersionMatches;
  final bool needsBackup;
  final bool noBackup;
  final bool passphraseAlwaysOnDevice;
  final bool passphraseProtection;
  final bool pinProtection;
  final bool recoveryMode;
  final bool sdCardPresent;
  final bool sdProtection;
  final bool unfinishedBackup;
  final bool unlocked;
  final bool wipeCodeProtection;
  final int autoLockDelayMs;
  final int displayRotation;
  final int flags;
  final int homescreenHeight;
  final int homescreenWidth;
  final int majorVersion;
  final int minorVersion;
  final int patchVersion;
  final String deviceId;
  final String fwVendor;
  final String internalModel;
  final String label;
  final String language;
  final String model;
  final String vendor;
  final BackupType backupType;
  final HomescreenFormat homescreenFormat;
  final Iterable<Features_Capability> capabilities;
  final List<int> revision;
  final SafetyCheckLevel safetyChecks;

  final List<int>? sessionId;

  TrezorPropertiesResponse({
    required this.busy,
    required this.experimentalFeatures,
    required this.hidePassphraseFromHost,
    required this.initialized,
    required this.languageVersionMatches,
    required this.needsBackup,
    required this.noBackup,
    required this.passphraseAlwaysOnDevice,
    required this.passphraseProtection,
    required this.pinProtection,
    required this.recoveryMode,
    required this.sdCardPresent,
    required this.sdProtection,
    required this.unfinishedBackup,
    required this.unlocked,
    required this.wipeCodeProtection,
    required this.autoLockDelayMs,
    required this.displayRotation,
    required this.flags,
    required this.homescreenHeight,
    required this.homescreenWidth,
    required this.majorVersion,
    required this.minorVersion,
    required this.patchVersion,
    required this.deviceId,
    required this.fwVendor,
    required this.internalModel,
    required this.label,
    required this.language,
    required this.model,
    required this.vendor,
    required this.backupType,
    required this.homescreenFormat,
    required this.capabilities,
    required this.revision,
    required this.safetyChecks,
    this.sessionId,
  });

  factory TrezorPropertiesResponse.defaultResponse({List<int>? sessionId}) {
    if (sessionId != null && sessionId.isEmpty) {
      sessionId = BytesUtils.generateRandomBytes(32);
    }
    return TrezorPropertiesResponse(
      busy: false,
      experimentalFeatures: false,
      hidePassphraseFromHost: false,
      initialized: true,
      languageVersionMatches: true,
      needsBackup: false,
      noBackup: false,
      passphraseAlwaysOnDevice: false,
      passphraseProtection: true,
      pinProtection: true,
      recoveryMode: false,
      sdCardPresent: true,
      sdProtection: false,
      unfinishedBackup: false,
      unlocked: true,
      wipeCodeProtection: false,
      autoLockDelayMs: 600000,
      displayRotation: 0,
      flags: 0,
      homescreenHeight: 240,
      homescreenWidth: 240,
      majorVersion: 2,
      minorVersion: 8,
      patchVersion: 1,
      deviceId: '355C817510C0EABF2F147145',
      fwVendor: 'EMULATOR',
      internalModel: 'T2T1',
      label: 'My Trezor',
      language: 'en-US',
      model: 'T',
      vendor: 'trezor.io',
      backupType: BackupType.Bip39,
      homescreenFormat: HomescreenFormat.Jpeg,
      capabilities: const <Features_Capability>[
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
      revision: const <int>[199, 131, 44, 57, 171, 60, 42, 156, 70, 84, 76, 87, 209, 168, 152, 5, 131, 96, 159, 71],
      safetyChecks: SafetyCheckLevel.Strict,
      sessionId: sessionId,
    );
  }

  @override
  GeneratedMessage toProtobufMsg() {
    return Features(
      busy: busy,
      experimentalFeatures: experimentalFeatures,
      hidePassphraseFromHost: hidePassphraseFromHost,
      initialized: initialized,
      languageVersionMatches: languageVersionMatches,
      needsBackup: needsBackup,
      noBackup: noBackup,
      passphraseAlwaysOnDevice: passphraseAlwaysOnDevice,
      passphraseProtection: passphraseProtection,
      pinProtection: pinProtection,
      recoveryMode: recoveryMode,
      sdCardPresent: sdCardPresent,
      sdProtection: sdProtection,
      unfinishedBackup: unfinishedBackup,
      unlocked: unlocked,
      wipeCodeProtection: wipeCodeProtection,
      autoLockDelayMs: autoLockDelayMs,
      displayRotation: displayRotation,
      flags: flags,
      homescreenHeight: homescreenHeight,
      homescreenWidth: homescreenWidth,
      majorVersion: majorVersion,
      minorVersion: minorVersion,
      patchVersion: patchVersion,
      deviceId: deviceId,
      fwVendor: fwVendor,
      internalModel: internalModel,
      label: label,
      language: language,
      model: model,
      vendor: vendor,
      backupType: backupType,
      homescreenFormat: homescreenFormat,
      capabilities: capabilities,
      revision: revision,
      safetyChecks: safetyChecks,
      sessionId: sessionId,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        busy,
        experimentalFeatures,
        hidePassphraseFromHost,
        initialized,
        languageVersionMatches,
        needsBackup,
        noBackup,
        passphraseAlwaysOnDevice,
        passphraseProtection,
        pinProtection,
        recoveryMode,
        sdCardPresent,
        sdProtection,
        unfinishedBackup,
        unlocked,
        wipeCodeProtection,
        autoLockDelayMs,
        displayRotation,
        flags,
        homescreenHeight,
        homescreenWidth,
        majorVersion,
        minorVersion,
        patchVersion,
        deviceId,
        fwVendor,
        internalModel,
        label,
        language,
        model,
        vendor,
        backupType,
        homescreenFormat,
        capabilities,
        revision,
        safetyChecks,
        sessionId
      ];
}
