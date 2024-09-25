import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_eth_msg_signature_response.dart';
import 'package:mirage/shared/models/pubkey_model.dart';
import 'package:mirage/shared/utils/cbor_utils.dart';

class TrezorEthMsgSignatureRequest extends ATrezorInteractiveRequest {
  final List<int> derivationPath;
  final List<int> message;

  TrezorEthMsgSignatureRequest({
    required this.derivationPath,
    required this.message,
  });

  factory TrezorEthMsgSignatureRequest.fromProtobufMsg(EthereumSignMessage ethereumSignMessage) {
    return TrezorEthMsgSignatureRequest(
      derivationPath: ethereumSignMessage.addressN,
      message: ethereumSignMessage.message,
    );
  }

  @override
  List<String> get description => <String>[];

  @override
  Uint8List toSerializedCbor({PubkeyModel? pubkeyModel}) {
    PubkeyModel derivedPubkeyModel = pubkeyModel!.derive(derivationPath.last);
    List<CborPathComponent> cborPathComponents = CborUtils.convertToPathComponents(derivationPath);
    CborCryptoKeypath cborCryptoKeypath = CborCryptoKeypath(components: cborPathComponents);

    CborEthSignRequest cborEthSignRequest = CborEthSignRequest(
      derivationPath: cborCryptoKeypath,
      dataType: CborEthSignDataType.rawBytes,
      signData: Uint8List.fromList(message),
      address: derivedPubkeyModel.ethereumAddress,
      requestId: Uint8List.fromList(<int>[1]),
    );
    return cborEthSignRequest.toSerializedCbor(includeTagBool: false);
  }

  @override
  Future<ATrezorAwaitedResponse> getResponseFromCborPayload(String payload, {PubkeyModel? pubkeyModel}) async {
    PubkeyModel derivedPubkeyModel = pubkeyModel!.derive(derivationPath.last);
    Uint8List payloadBytes = HexCodec.decode(payload);
    String address = derivedPubkeyModel.ethereumAddress;
    return TrezorEthMsgSignatureResponse.fromSerializedCbor(payloadBytes, address);
  }

  @override
  String get title => 'Signing Ethereum Message';

  @override
  List<Object?> get props => <Object>[derivationPath, message];
}
