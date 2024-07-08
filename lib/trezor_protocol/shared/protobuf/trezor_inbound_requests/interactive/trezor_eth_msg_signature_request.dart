import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/a_trezor_supplementary_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/trezor_wait_for_response_agreement.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/trezor_eth_msg_signature_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/trezor_ask_to_wait_response.dart';

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
  ATrezorOutboundResponse askForSupplementaryInfo() {
    return TrezorAskToWaitResponse.ethMsgSignature();
  }

  @override
  ATrezorInteractiveRequest fillWithAnotherRequest(ATrezorSupplementaryRequest trezorSupplementaryRequest) {
    if (trezorSupplementaryRequest is TrezorWaitForResponseAgreement) {
      return TrezorEthMsgSignatureRequest(
        waitingAgreedBool: true,
        derivationPath: derivationPath,
        message: message,
      );
    } else {
      return this;
    }
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
  bool get requestReadyBool => waitingAgreedBool;

  @override
  List<Object?> get props => <Object>[derivationPath, message];
}
