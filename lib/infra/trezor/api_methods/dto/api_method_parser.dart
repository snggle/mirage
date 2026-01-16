import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_sign_msg.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_sign_tx.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/get_public_key.dart';

class ApiMethodParser {
  static AApiMethodDto fromWsPayloadJson(Map<String, dynamic> payloadJson) {
    String type = payloadJson['method'] as String;

    switch (type) {
      case 'getPublicKey':
        return GetPublicKey.fromJson(payloadJson);
      case 'ethereumSignTransaction':
        return EthSignTx.fromJson(payloadJson);
      case 'ethereumSignMessage':
        return EthSignMsg.fromJson(payloadJson);
      default:
        throw ArgumentError('Unknown message type: $type');
    }
  }
}
