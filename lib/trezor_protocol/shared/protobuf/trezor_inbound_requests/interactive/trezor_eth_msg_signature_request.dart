import 'package:cbor/cbor.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/trezor_eth_msg_signature_response.dart';

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
  Future<ATrezorAwaitedResponse> getResponseFromCborPayload(String payload) async {
    List<int> payloadBytes = BytesUtils.convertHexToBytes(payload);
    Stream<List<int>> byteStream = Stream<List<int>>.fromIterable(<List<int>>[payloadBytes]);
    CborValue cborValue = await byteStream.transform(cbor.decoder).single;

    return TrezorEthMsgSignatureResponse.fromCborValue(cborValue);
  }

  @override
  String get title => 'Signing Ethereum Message';

  @override
  String get requestCbor => BytesUtils.convertBytesToHex(cbor.encode(CborValue(<Object>[derivationPath, message])));

  @override
  List<Object?> get props => <Object>[derivationPath, message];
}
