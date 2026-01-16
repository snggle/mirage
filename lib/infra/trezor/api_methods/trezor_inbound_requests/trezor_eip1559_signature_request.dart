import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_access_list_item.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_sign_tx.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/trezor_eip1559_signature_response.dart';
import 'package:mirage/shared/models/pubkey_model.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:mirage/shared/utils/cbor_utils.dart';

class TrezorEIP1559SignatureRequest extends ATrezorInboundRequest {
  final List<CborPathComponent> derivationPath;
  final EthereumEIP1559Transaction ethereumEIP1559Transaction;

  TrezorEIP1559SignatureRequest({
    required this.derivationPath,
    required this.ethereumEIP1559Transaction,
  });

  factory TrezorEIP1559SignatureRequest.fromDto(EthSignTx ethSignTx) {
    EthereumEIP1559Transaction ethereumEIP1559Transaction = EthereumEIP1559Transaction(
      chainId: BigInt.parse(ethSignTx.transaction.chainId.toString()),
      nonce: _parseHexToBigInt(ethSignTx.transaction.nonce),
      maxPriorityFeePerGas: _parseHexToBigInt(ethSignTx.transaction.maxPriorityFeePerGas),
      maxFeePerGas: _parseHexToBigInt(ethSignTx.transaction.maxFeePerGas),
      gasLimit: _parseHexToBigInt(ethSignTx.transaction.gasLimit),
      to: ethSignTx.transaction.to,
      value: _parseHexToBigInt(ethSignTx.transaction.value),
      data: ethSignTx.transaction.data == null ? Uint8List.fromList(<int>[]) : BytesUtils.convertHexToBytes(ethSignTx.transaction.data!),
      accessList: ethSignTx.transaction.accessList.map((EthAccessListItem ethAccessListItem) {
        return AccessListBytesItem(
          HexCodec.decode(ethAccessListItem.address),
          ethAccessListItem.storageKeys.map(BytesUtils.convertHexToBytes).toList(),
        );
      }).toList(),
    );
    return TrezorEIP1559SignatureRequest(
      derivationPath: CborUtils.pathToCbor(ethSignTx.path),
      ethereumEIP1559Transaction: ethereumEIP1559Transaction,
    );
  }

  @override
  List<String> get description {
    return <String>['Sending tokens to 0x${ethereumEIP1559Transaction.to}'];
  }

  @override
  Uint8List toSerializedCbor({PubkeyModel? pubkeyModel}) {
    PubkeyModel derivedPubkeyModel = pubkeyModel!.derive(derivationPath.last.index);
    CborCryptoKeypath cborCryptoKeypath = CborCryptoKeypath(components: derivationPath);

    CborEthSignRequest cborEthSignRequest = CborEthSignRequest(
      derivationPath: cborCryptoKeypath,
      dataType: CborEthSignDataType.transactionData,
      signData: ethereumEIP1559Transaction.serialize(),
      chainId: ethereumEIP1559Transaction.chainId.toInt(),
      address: derivedPubkeyModel.ethereumAddress,
      requestId: Uint8List.fromList(<int>[1]),
    );
    return cborEthSignRequest.toSerializedCbor(includeTagBool: true);
  }

  @override
  Future<ATrezorOutboundResponse> getResponseFromCborPayload(Uint8List payloadBytes) async {
    return TrezorEIP1559SignatureResponse.fromSerializedCbor(payloadBytes);
  }

  @override
  String get title => 'Signing EIP1559 Transaction';

  static BigInt _parseHexToBigInt(String? hex) {
    if (hex == null || hex == '0x' || hex == '') {
      return BigInt.zero;
    }
    return BytesUtils.convertHexToBigInt(hex);
  }

  @override
  List<Object?> get props => <Object?>[derivationPath, ethereumEIP1559Transaction];
}
