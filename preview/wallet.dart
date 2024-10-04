import 'package:cryptography_utils/cryptography_utils.dart';

// ignore_for_file: avoid_print
class Wallet {
  static String mnemonicPhrase = 'carry pave input birth pole vague elephant moment either science food donkey'; // used accounts: Trezor 1, Trezor 2
  // static String mnemonicPhrase = 'exile narrow attract fly work glide pupil raccoon cabin digital pull topple'; // used accounts: Trezor 3
  static LegacyWalletConfig<ABip32PrivateKey> walletConfig = Bip44WalletsConfig.ethereum;
  static LegacyDerivationPath legacyDerivationPath = LegacyDerivationPath.parse("m/44'/60'/0'/0/0");
}
