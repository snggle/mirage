import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_eth_msg_signature_response.dart';
import 'package:mirage/shared/utils/app_logger.dart';

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
  ATrezorAwaitedResponse getResponseFromUser() {
    _logRequestData();
    return TrezorEthMsgSignatureResponse.getDataFromUser();
  }

  void _logRequestData() {
    AppLogger().log(message: '*** Signing Ethereum Message ***');
    AppLogger().log(message: 'derivation path: ${derivationPath}');
    AppLogger().log(message: 'message: $message');
    AppLogger().log(message: 'Enter the values');
  }

  @override
  List<Object?> get props => <Object>[derivationPath, message];
}
