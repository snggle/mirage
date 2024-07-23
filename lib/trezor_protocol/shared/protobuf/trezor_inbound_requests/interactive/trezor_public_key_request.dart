import 'package:cbor/cbor.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';
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
  Future<ATrezorAwaitedResponse> getResponseFromCborPayload(String payload) async {
    List<int> payloadBytes = BytesUtils.convertHexToBytes(payload);
    Stream<List<int>> byteStream = Stream<List<int>>.fromIterable(<List<int>>[payloadBytes]);
    CborValue cborValue = await byteStream.transform(cbor.decoder).single;

    return TrezorPublicKeyResponse.fromCborValue(cborValue);
  }

  @override
  String get title => '*** Exporting Public Key ***';

  @override
  String get requestCbor => BytesUtils.convertBytesToHex(cbor.encode(CborValue(<Object>[derivationPath])));

  @override
  List<Object?> get props => <Object>[derivationPath];
}
