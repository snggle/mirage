import 'package:cryptography_utils/cryptography_utils.dart' as cryptography_utils;
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/automated/a_trezor_automated_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';
import 'package:mirage/infra/trezor/public_key_model.dart';
import 'package:mirage/infra/trezor/trezor_communication_notifier.dart';

class TrezorDerivedPublicKeyRequest extends ATrezorAutomatedRequest {
  final bool waitingAgreedBool;
  final List<int> derivationPath;

  TrezorDerivedPublicKeyRequest({
    required this.waitingAgreedBool,
    required this.derivationPath,
  });

  factory TrezorDerivedPublicKeyRequest.fromProtobufMsg(GetPublicKey getPublicKey) {
    return TrezorDerivedPublicKeyRequest(
      waitingAgreedBool: false,
      derivationPath: getPublicKey.addressN,
    );
  }

  @override
  ATrezorOutboundResponse getResponse() {
    cryptography_utils.Secp256k1Derivator secp256k1Derivator = cryptography_utils.Secp256k1Derivator();
    PubkeyModel savedPubkeyModel = globalLocator<TrezorCommunicationNotifier>().savedPubkeyModel;

    cryptography_utils.Secp256k1PublicKey savedSecp256k1Pubkey = savedPubkeyModel.secp256k1publicKey;

    cryptography_utils.Secp256k1PublicKey derivedSecp256k1PubKey =
        secp256k1Derivator.derivePublicKey(savedSecp256k1Pubkey, cryptography_utils.LegacyDerivationPathElement.parse('0'));

    return TrezorPublicKeyResponse(
      depth: derivationPath.length,
      fingerprint: derivedSecp256k1PubKey.metadata.parentFingerprint!.toInt(),
      chainCode: derivedSecp256k1PubKey.metadata.chainCode!,
      publicKey: derivedSecp256k1PubKey.compressed,
      xpub: derivedSecp256k1PubKey.getExtendedPublicKey(),
    );
  }

  @override
  List<Object?> get props => <Object>[derivationPath];
}
