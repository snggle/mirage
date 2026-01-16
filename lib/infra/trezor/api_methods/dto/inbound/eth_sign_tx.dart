import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_transaction.dart';

class EthSignTx extends AApiMethodDto {
  final String path;
  final EthTransaction transaction;

  EthSignTx({
    required this.path,
    required this.transaction,
  });

  factory EthSignTx.fromJson(Map<String, dynamic> json) {
    return EthSignTx(
      path: json['path'] as String,
      transaction: EthTransaction.fromJson(
        json['transaction'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'path': path,
      'transaction': transaction.toJson(),
    };
  }

  @override
  List<Object> get props => <Object>[path, transaction];

}
