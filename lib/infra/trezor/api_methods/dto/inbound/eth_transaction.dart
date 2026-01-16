import 'package:equatable/equatable.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_access_list_item.dart';

class EthTransaction extends Equatable {
  final int chainId;
  final String gasLimit;
  final String nonce;
  final String to;
  final String value;
  final List<EthAccessListItem> accessList;
  final String? data;
  final String? maxFeePerGas;
  final String? maxPriorityFeePerGas;
  final String? type;
  // TODO(marcin): field payment_req containing token info is not yet implemented on Trezor side

  const EthTransaction({
    required this.chainId,
    required this.gasLimit,
    required this.nonce,
    required this.to,
    required this.value,
    required this.accessList,
    this.data,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    this.type,
  });

  factory EthTransaction.fromJson(Map<String, dynamic> json) {
    final List<dynamic> accessListJson = json['accessList'] as List<dynamic>;

    return EthTransaction(
      chainId: json['chainId'] as int,
      gasLimit: json['gasLimit'] as String,
      nonce: json['nonce'] as String,
      to: json['to'] as String,
      value: json['value'] as String,
      data: json['data'] as String?,
      maxFeePerGas: json['maxFeePerGas'] as String?,
      maxPriorityFeePerGas: json['maxPriorityFeePerGas'] as String?,
      type: json['type'] as String?,
      accessList: accessListJson.isEmpty
          ? <EthAccessListItem>[]
          : accessListJson.map((dynamic e) => EthAccessListItem.fromJson(e as Map<String, dynamic>)).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'chainId': chainId,
      'gasLimit': gasLimit,
      'nonce': nonce,
      'to': to,
      'value': value,
      'accessList': accessList,
      if (data != null) 'data': data,
      if (maxFeePerGas != null) 'maxFeePerGas': maxFeePerGas,
      if (maxPriorityFeePerGas != null) 'maxPriorityFeePerGas': maxPriorityFeePerGas,
      if (type != null) 'type': type,
    };
  }

  @override
  List<Object?> get props => <Object?>[chainId, gasLimit, nonce, to, value, accessList, data, maxFeePerGas, maxPriorityFeePerGas, type];
}
