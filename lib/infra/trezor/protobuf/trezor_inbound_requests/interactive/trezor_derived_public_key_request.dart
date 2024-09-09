import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';

class TrezorDerivedPublicKeyRequest extends ATrezorInteractiveRequest {
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

  TrezorPublicKeyResponse getResponse(Secp256k1PublicKey secp256k1publicKey) {
    return TrezorPublicKeyResponse(
      depth: derivationPath.length,
      fingerprint: secp256k1publicKey.metadata.parentFingerprint!.toInt(),
      chainCode: secp256k1publicKey.metadata.chainCode!,
      publicKey: secp256k1publicKey.compressed,
      xpub: secp256k1publicKey.getExtendedPublicKey(),
    );
  }

  @override
  List<Object?> get props => <Object>[derivationPath];

  @override
  List<String> get description => throw UnimplementedError();

  @override
  List<String> get expectedResponseStructure => throw UnimplementedError();

  @override
  Map<String, String> getRequestData() {
    throw UnimplementedError();
  }

  @override
  ATrezorAwaitedResponse getResponseFromUserInput(List<String> userInput) {
    throw UnimplementedError();
  }

  @override
  String get title => throw UnimplementedError();
}
