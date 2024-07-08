import 'dart:typed_data';

import 'package:cryptography_utils/cryptography_utils.dart' as cryptography_utils;
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum-definitions.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/a_trezor_supplementary_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/trezor_tx_data_supply.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/trezor_wait_for_response_agreement.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/trezor_eip1559_signature_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/trezor_ask_more_data_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/trezor_ask_to_wait_response.dart';

class TrezorEIP1559SignatureRequest extends ATrezorInteractiveRequest {
  final bool waitingAgreedBool;
  final cryptography_utils.EthereumEIP1559Transaction ethereumEIP1559Transaction;
  final int dataLength;
  final List<int> derivationPath;
  final String? token;

  TrezorEIP1559SignatureRequest({
    required this.waitingAgreedBool,
    required this.ethereumEIP1559Transaction,
    required this.dataLength,
    required this.derivationPath,
    this.token,
  });

  factory TrezorEIP1559SignatureRequest.fromProtobufMsg(EthereumSignTxEIP1559 ethereumSignTxEIP1559) {
    cryptography_utils.EthereumEIP1559Transaction ethereumEIP1559Transaction = cryptography_utils.EthereumEIP1559Transaction(
      chainId: BigInt.parse(ethereumSignTxEIP1559.chainId.toString()),
      nonce: BytesUtils.convertBytesToBigInt(ethereumSignTxEIP1559.nonce),
      maxPriorityFeePerGas: BytesUtils.convertBytesToBigInt(ethereumSignTxEIP1559.maxPriorityFee),
      maxFeePerGas: BytesUtils.convertBytesToBigInt(ethereumSignTxEIP1559.maxGasFee),
      gasLimit: BytesUtils.convertBytesToBigInt(ethereumSignTxEIP1559.gasLimit),
      to: ethereumSignTxEIP1559.to,
      value: BytesUtils.convertBytesToBigInt(ethereumSignTxEIP1559.value),
      data: Uint8List.fromList(ethereumSignTxEIP1559.dataInitialChunk),
      accessList: ethereumSignTxEIP1559.accessList.map((EthereumSignTxEIP1559_EthereumAccessList accessListBytesItem) {
        return cryptography_utils.AccessListBytesItem(
          BytesUtils.convertHexToBytes(accessListBytesItem.address),
          accessListBytesItem.storageKeys.map((List<int> storageKey) {
            return Uint8List.fromList(storageKey);
          }).toList(),
        );
      }).toList(),
    );
    return TrezorEIP1559SignatureRequest(
      waitingAgreedBool: false,
      ethereumEIP1559Transaction: ethereumEIP1559Transaction,
      dataLength: ethereumSignTxEIP1559.dataLength,
      derivationPath: ethereumSignTxEIP1559.addressN,
      token: _getToken(ethereumSignTxEIP1559) ?? ethereumEIP1559Transaction.getAmount(cryptography_utils.TokenDenominationType.network).denomination.toString(),
    );
  }

  @override
  ATrezorOutboundResponse askForSupplementaryInfo() {
    bool completeDataBool = dataLength == ethereumEIP1559Transaction.data.length;

    if (completeDataBool) {
      return TrezorAskToWaitResponse.eip1559Signature();
    } else {
      int missingDataLength = dataLength - ethereumEIP1559Transaction.data.length;
      if (missingDataLength <= 1024) {
        return TrezorAskMoreDataResponse(requestedBytesLength: missingDataLength);
      } else {
        return TrezorAskMoreDataResponse(requestedBytesLength: 1024);
      }
    }
  }

  @override
  TrezorEIP1559SignatureRequest fillWithAnotherRequest(ATrezorSupplementaryRequest trezorSupplementaryRequest) {
    if (trezorSupplementaryRequest is TrezorWaitForResponseAgreement) {
      return _copyWith(waitingAgreedBool: true);
    } else if (trezorSupplementaryRequest is TrezorTxDataSupply) {
      Uint8List newData = trezorSupplementaryRequest.dataChunk;
      Uint8List filledData = BytesUtils.mergeBytes(<Uint8List>[ethereumEIP1559Transaction.data, newData]);
      return _copyWith(data: filledData);
    } else {
      throw ArgumentError();
    }
  }

  @override
  ATrezorAwaitedResponse getResponseFromUser() {
    _logRequestData();
    return TrezorEIP1559SignatureResponse.getDataFromUser();
  }

  TrezorEIP1559SignatureRequest _copyWith({bool? waitingAgreedBool, Uint8List? data}) {
    return TrezorEIP1559SignatureRequest(
      waitingAgreedBool: waitingAgreedBool ?? this.waitingAgreedBool,
      ethereumEIP1559Transaction: cryptography_utils.EthereumEIP1559Transaction(
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

  void _logRequestData() {
    String amount = ethereumEIP1559Transaction.getAmount(cryptography_utils.TokenDenominationType.network).amount.toString();
    AppLogger().log(message: '*** Signing EIP1559 Transaction ***');
    AppLogger().log(message: '*** Token: $token ***');
    AppLogger().log(message: '*** Sending $amount to 0x${ethereumEIP1559Transaction.to} ***');
    AppLogger().log(message: 'derivation path: ${derivationPath}');
    AppLogger().log(message: 'sign data: ${ethereumEIP1559Transaction.serialize()}');
    AppLogger().log(message: 'Enter the values');
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
  bool get requestReadyBool {
    bool dataCompleteBool = dataLength == ethereumEIP1559Transaction.data.length;
    return waitingAgreedBool && dataCompleteBool;
  }

  @override
  List<Object?> get props => <Object?>[ethereumEIP1559Transaction, dataLength, derivationPath, token];
}
