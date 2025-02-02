import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum-definitions.pb.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/multipart/a_trezor_multipart_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/supplementary/a_trezor_supplementary_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/supplementary/trezor_eip1559_data_supply.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_eip1559_signature_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/trezor_ask_more_data_response.dart';
import 'package:mirage/shared/models/pubkey_model.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:mirage/shared/utils/cbor_utils.dart';

class TrezorEIP1559SignatureRequest extends ATrezorMultipartInteractiveRequest {
  final EthereumEIP1559Transaction ethereumEIP1559Transaction;
  final int dataLength;
  final List<int> derivationPath;
  final String? token;

  TrezorEIP1559SignatureRequest({
    required this.ethereumEIP1559Transaction,
    required this.dataLength,
    required this.derivationPath,
    this.token,
  });

  factory TrezorEIP1559SignatureRequest.fromProtobufMsg(EthereumSignTxEIP1559 ethereumSignTxEIP1559) {
    EthereumEIP1559Transaction ethereumEIP1559Transaction = EthereumEIP1559Transaction(
      chainId: BigInt.parse(ethereumSignTxEIP1559.chainId.toString()),
      nonce: BytesUtils.convertBytesToBigInt(ethereumSignTxEIP1559.nonce),
      maxPriorityFeePerGas: BytesUtils.convertBytesToBigInt(ethereumSignTxEIP1559.maxPriorityFee),
      maxFeePerGas: BytesUtils.convertBytesToBigInt(ethereumSignTxEIP1559.maxGasFee),
      gasLimit: BytesUtils.convertBytesToBigInt(ethereumSignTxEIP1559.gasLimit),
      to: ethereumSignTxEIP1559.to,
      value: BytesUtils.convertBytesToBigInt(ethereumSignTxEIP1559.value),
      data: Uint8List.fromList(ethereumSignTxEIP1559.dataInitialChunk),
      accessList: ethereumSignTxEIP1559.accessList.map((EthereumSignTxEIP1559_EthereumAccessList accessListBytesItem) {
        return AccessListBytesItem(
          HexCodec.decode(accessListBytesItem.address),
          accessListBytesItem.storageKeys.map((List<int> storageKey) {
            return Uint8List.fromList(storageKey);
          }).toList(),
        );
      }).toList(),
    );
    return TrezorEIP1559SignatureRequest(
      ethereumEIP1559Transaction: ethereumEIP1559Transaction,
      dataLength: ethereumSignTxEIP1559.dataLength,
      derivationPath: ethereumSignTxEIP1559.addressN,
      token: _getToken(ethereumSignTxEIP1559) ?? ethereumEIP1559Transaction.getAmount(TokenDenominationType.network).denomination.toString(),
    );
  }

  @override
  TrezorAskMoreDataResponse askForSupplementaryInfo() {
    int missingDataLength = dataLength - ethereumEIP1559Transaction.data.length;
    if (missingDataLength <= 1024) {
      return TrezorAskMoreDataResponse(requestedBytesLength: missingDataLength);
    } else {
      return TrezorAskMoreDataResponse(requestedBytesLength: 1024);
    }
  }

  @override
  TrezorEIP1559SignatureRequest fillData(ATrezorSupplementaryRequest trezorSupplementaryRequest) {
    if (trezorSupplementaryRequest is TrezorEIP1559DataSupply) {
      Uint8List newData = trezorSupplementaryRequest.dataChunk;
      Uint8List filledData = BytesUtils.mergeBytes(<Uint8List>[ethereumEIP1559Transaction.data, newData]);
      return _copyWith(data: filledData);
    } else {
      throw ArgumentError();
    }
  }

  @override
  bool get requestReady => dataLength == ethereumEIP1559Transaction.data.length;

  @override
  List<String> get description {
    String amount = ethereumEIP1559Transaction.getAmount(TokenDenominationType.network).amount.toString();
    return <String>['Token: $token', 'Sending $amount to 0x${ethereumEIP1559Transaction.to}'];
  }

  @override
  Uint8List toSerializedCbor({PubkeyModel? pubkeyModel}) {
    PubkeyModel derivedPubkeyModel = pubkeyModel!.derive(derivationPath.last);
    List<CborPathComponent> cborPathComponents = CborUtils.convertToPathComponents(derivationPath);
    CborCryptoKeypath cborCryptoKeypath = CborCryptoKeypath(components: cborPathComponents);

    CborEthSignRequest cborEthSignRequest = CborEthSignRequest(
      derivationPath: cborCryptoKeypath,
      dataType: CborEthSignDataType.transactionData,
      signData: ethereumEIP1559Transaction.serialize(),
      chainId: ethereumEIP1559Transaction.chainId.toInt(),
      address: derivedPubkeyModel.ethereumAddress,
      requestId: Uint8List.fromList(<int>[1]),
    );
    return cborEthSignRequest.toSerializedCbor(includeTagBool: false);
  }

  @override
  Future<ATrezorAwaitedResponse> getResponseFromCborPayload(String payload, {PubkeyModel? pubkeyModel}) async {
    Uint8List payloadBytes = HexCodec.decode(payload);
    return TrezorEIP1559SignatureResponse.fromSerializedCbor(payloadBytes);
  }

  @override
  String get title => 'Signing EIP1559 Transaction';

  TrezorEIP1559SignatureRequest _copyWith({Uint8List? data}) {
    return TrezorEIP1559SignatureRequest(
      ethereumEIP1559Transaction: EthereumEIP1559Transaction(
        chainId: ethereumEIP1559Transaction.chainId,
        nonce: ethereumEIP1559Transaction.nonce,
        maxPriorityFeePerGas: ethereumEIP1559Transaction.maxPriorityFeePerGas,
        maxFeePerGas: ethereumEIP1559Transaction.maxFeePerGas,
        gasLimit: ethereumEIP1559Transaction.gasLimit,
        to: ethereumEIP1559Transaction.to,
        value: ethereumEIP1559Transaction.value,
        data: data ?? ethereumEIP1559Transaction.data,
        accessList: ethereumEIP1559Transaction.accessList,
      ),
      dataLength: dataLength,
      derivationPath: derivationPath,
      token: token,
    );
  }

  static String? _getToken(EthereumSignTxEIP1559 ethereumSignTxEIP1559) {
    String? token;

    List<int> encodedNetwork = ethereumSignTxEIP1559.definitions.encodedNetwork;
    List<int> encodedToken = ethereumSignTxEIP1559.definitions.encodedToken;

    if (encodedNetwork.isNotEmpty) {
      token = _getNetworkInfo(encodedNetwork);
    }

    if (encodedToken.isNotEmpty) {
      token = _getTokenInfo(encodedToken);
    }

    return token;
  }

  static String _getNetworkInfo(List<int> encodedNetwork) {
    Uint8List protobufPayloadLengthBytes = Uint8List.fromList(encodedNetwork.sublist(10, 12));
    int protobufPayloadLength = BytesUtils.convertBytesToInt(protobufPayloadLengthBytes, endian: Endian.little);

    List<int> protobufPayload = encodedNetwork.sublist(12, 12 + protobufPayloadLength);
    EthereumNetworkInfo ethereumNetworkInfo = EthereumNetworkInfo.fromBuffer(protobufPayload);
    return '${ethereumNetworkInfo.name} ${ethereumNetworkInfo.symbol}';
  }

  static String _getTokenInfo(List<int> encodedToken) {
    Uint8List protobufPayloadLengthBytes = Uint8List.fromList(encodedToken.sublist(10, 12));
    int protobufPayloadLength = BytesUtils.convertBytesToInt(protobufPayloadLengthBytes, endian: Endian.little);

    List<int> protobufPayload = encodedToken.sublist(12, 12 + protobufPayloadLength);
    EthereumTokenInfo ethereumTokenInfo = EthereumTokenInfo.fromBuffer(protobufPayload);
    return '${ethereumTokenInfo.name} ${ethereumTokenInfo.symbol}';
  }

  @override
  List<Object?> get props => <Object?>[ethereumEIP1559Transaction, dataLength, derivationPath, token];
}
