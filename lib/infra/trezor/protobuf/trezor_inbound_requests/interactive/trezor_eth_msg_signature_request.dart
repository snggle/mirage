import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_eth_msg_signature_response.dart';

class TrezorEthMsgSignatureRequest extends ATrezorInteractiveRequest {
  final bool waitingAgreedBool;
  final List<int> derivationPath;
  final List<int> message;

  TrezorEthMsgSignatureRequest({
    required this.waitingAgreedBool,
    required this.derivationPath,
    required this.message,
  });

  factory TrezorEthMsgSignatureRequest.fromProtobufMsg(EthereumSignMessage ethereumSignMessage) {
    return TrezorEthMsgSignatureRequest(
      waitingAgreedBool: false,
      derivationPath: ethereumSignMessage.addressN,
      message: ethereumSignMessage.message,
    );
  }

  @override
  List<String> get description => <String>[];

  @override
  // TODO(Marcin): temporary method before CBOR implementation
  List<String> get expectedResponseStructure => <String>[
    'Address',
    'Signature',
  ];

  @override
  // TODO(Marcin): replace with "toSerializedCbor()" after CBOR implementation
  Map<String, String> getRequestData() {
    return <String, String>{
      'Derivation path': derivationPath.toString(),
      'Message': message.toString(),
    };
  }

  @override
  ATrezorAwaitedResponse getResponseFromUserInput(List<String> userInput) {
    return TrezorEthMsgSignatureResponse.getDataFromUser(userInput);
  }

  @override
  String get title => 'Signing Ethereum Message';

  @override
  List<Object?> get props => <Object>[derivationPath, message];
}
