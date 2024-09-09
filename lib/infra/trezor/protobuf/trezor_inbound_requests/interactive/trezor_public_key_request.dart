import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';

class TrezorPublicKeyRequest extends ATrezorInteractiveRequest {
  final bool waitingAgreedBool;
  final List<int> derivationPath;

  TrezorPublicKeyRequest({
    required this.waitingAgreedBool,
    required this.derivationPath,
  });

  factory TrezorPublicKeyRequest.fromProtobufMsg(GetPublicKey getPublicKey) {
    return TrezorPublicKeyRequest(
      waitingAgreedBool: false,
      derivationPath: getPublicKey.addressN,
    );
  }

  @override
  List<String> get description => <String>[];

  @override
  // TODO(Marcin): temporary method before CBOR implementation
  List<String> get expectedResponseStructure => <String>[
        'Depth',
        'Fingerprint',
        'Chain Code',
        'Public Key',
        'XPub',
      ];

  @override
  // TODO(Marcin): replace with "toSerializedCbor()" after CBOR implementation
  Map<String, String> getRequestData() {
    return <String, String>{
      'Derivation path': derivationPath.toString(),
    };
  }

  @override
  TrezorPublicKeyResponse getResponseFromUserInput(List<String> userInput) {
    return TrezorPublicKeyResponse.getDataFromUser(userInput);
  }

  @override
  String get title => 'Exporting Public Key';

  @override
  List<Object?> get props => <Object>[derivationPath];
}
