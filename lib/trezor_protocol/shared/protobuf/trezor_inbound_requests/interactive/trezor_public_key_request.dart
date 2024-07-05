import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';

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
  ATrezorAwaitedResponse getResponseFromUser() {
    _logRequestData();
    return TrezorPublicKeyResponse.getDataFromUser();
  }

  void _logRequestData() {
    AppLogger().log(message: '*** Exporting Public Key ***');
    AppLogger().log(message: 'derivation path: ${derivationPath}');
    AppLogger().log(message: 'Enter the values');
  }

  @override
  List<Object?> get props => <Object>[derivationPath];
}
