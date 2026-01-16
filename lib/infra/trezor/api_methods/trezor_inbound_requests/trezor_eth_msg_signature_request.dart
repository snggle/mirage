import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_sign_msg.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/trezor_eth_msg_signature_response.dart';
import 'package:mirage/shared/models/pubkey_model.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:mirage/shared/utils/cbor_utils.dart';

class TrezorEthMsgSignatureRequest extends ATrezorInboundRequest {
  final List<CborPathComponent> derivationPath;
  final String message;

  TrezorEthMsgSignatureRequest({
    required this.derivationPath,
    required this.message,
  });

  factory TrezorEthMsgSignatureRequest.fromDto(EthSignMsg ethSignMsg) {
    return TrezorEthMsgSignatureRequest(
      derivationPath: CborUtils.pathToCbor(ethSignMsg.path),
      message: ethSignMsg.message,
    );
  }

  @override
  List<String> get description => <String>[];

  @override
  Uint8List toSerializedCbor({PubkeyModel? pubkeyModel}) {
    PubkeyModel derivedPubkeyModel = pubkeyModel!.derive(derivationPath.last.index);
    CborCryptoKeypath cborCryptoKeypath = CborCryptoKeypath(components: derivationPath);

    CborEthSignRequest cborEthSignRequest = CborEthSignRequest(
      derivationPath: cborCryptoKeypath,
      dataType: CborEthSignDataType.transactionData,
      signData: BytesUtils.convertHexToBytes(message),
      address: derivedPubkeyModel.ethereumAddress,
      requestId: Uint8List.fromList(<int>[1]),
    );
    return cborEthSignRequest.toSerializedCbor(includeTagBool: true);
  }

  @override
  Future<ATrezorOutboundResponse> getResponseFromCborPayload(Uint8List payloadBytes, {PubkeyModel? pubkeyModel}) async {
    PubkeyModel derivedPubkeyModel = pubkeyModel!.derive(derivationPath.last.index);
    String address = derivedPubkeyModel.ethereumAddress;
    return TrezorEthMsgSignatureResponse.fromSerializedCbor(payloadBytes, address);
  }

  @override
  String get title => 'Signing Ethereum Message';

  @override
  List<Object?> get props => <Object?>[derivationPath, message];
}
