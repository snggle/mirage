import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/a_trezor_supplementary_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/trezor_wait_for_response_agreement.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/trezor_ask_to_wait_response.dart';

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
  ATrezorOutboundResponse askForSupplementaryInfo() {
    return TrezorAskToWaitResponse.publicKey();
  }

  @override
  ATrezorAwaitedResponse getResponseFromUser() {
    _logRequestData();
    return TrezorPublicKeyResponse.getDataFromUser();
  }

  @override
  TrezorPublicKeyRequest fillWithAnotherRequest(ATrezorSupplementaryRequest trezorSupplementaryRequest) {
    if (trezorSupplementaryRequest is TrezorWaitForResponseAgreement) {
      return TrezorPublicKeyRequest(
        waitingAgreedBool: true,
        derivationPath: derivationPath,
      );
    } else {
      return this;
    }
  }

  void _logRequestData() {
    AppLogger().log(message: '*** Exporting Public Key ***');
    AppLogger().log(message: 'derivation path: ${derivationPath}');
    AppLogger().log(message: 'Enter the values');
  }

  @override
  bool get requestReadyBool => waitingAgreedBool;

  @override
  List<Object?> get props => <Object>[derivationPath];
}
