import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/infra/trezor/api_methods/dto/a_api_method_dto.dart';
import 'package:mirage/infra/trezor/api_methods/dto/api_method_parser.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_access_list_item.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_sign_msg.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_sign_tx.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/eth_transaction.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/get_public_key.dart';

void main() {
  group('Tests of ApiMethodParser.fromWsPayloadJson()', () {
    test('Should [return GetPublicKey] when method is getPublicKey', () {
      // Arrange
      Map<String, dynamic> actualPayloadJson = <String, dynamic>{
        'path': "m/44'/60'/0'/0",
        'coin': 'ETH',
        'method': 'getPublicKey',
      };

      // Act
      AApiMethodDto actualApiMethodDto = ApiMethodParser.fromWsPayloadJson(actualPayloadJson);

      // Assert
      AApiMethodDto expectedApiMethodDto = GetPublicKey(
        path: "m/44'/60'/0'/0",
        coin: 'ETH',
      );

      expect(actualApiMethodDto, expectedApiMethodDto);
    });

    test('Should [return EthSignTx] when method is ethereumSignTransaction', () {
      // Arrange
      Map<String, dynamic> actualPayloadJson = <String, dynamic>{
        'path': "m/44'/60'/0'/0/1",
        'transaction': <String, Object>{
          'type': '0x2',
          'nonce': '0xf',
          'gasLimit': '0x7b0c',
          'to': '0xf9b003291102d057bb0fb52bfb22fb7604a408bd',
          'value': '0x2386f26fc10000',
          'data': '0x',
          'chainId': 11155111,
          'maxPriorityFeePerGas': '0x59682f00',
          'maxFeePerGas': '0xaf4f83a2',
          'accessList': <dynamic>[]
        },
        'method': 'ethereumSignTransaction'
      };

      // Act
      AApiMethodDto actualApiMethodDto = ApiMethodParser.fromWsPayloadJson(actualPayloadJson);

      // Assert
      AApiMethodDto expectedApiMethodDto = EthSignTx(
        path: "m/44'/60'/0'/0/1",
        transaction: const EthTransaction(
          chainId: 11155111,
          gasLimit: '0x7b0c',
          nonce: '0xf',
          to: '0xf9b003291102d057bb0fb52bfb22fb7604a408bd',
          value: '0x2386f26fc10000',
          accessList: <EthAccessListItem>[],
          data: '0x',
          maxFeePerGas: '0xaf4f83a2',
          maxPriorityFeePerGas: '0x59682f00',
          type: '0x2',
        ),
      );

      expect(actualApiMethodDto, expectedApiMethodDto);
    });

    test('Should [return EthSignMsg] when method is ethereumSignMessage', () {
      // Arrange
      Map<String, dynamic> actualPayloadJson = <String, dynamic>{
        'path': "m/44'/60'/0'/0/1",
        'message':
            '6f70656e7365612e696f2077616e747320796f7520746f207369676e20696e207769746820796f7572206163636f756e743a0a3078333864653833343331383437366463646263616539653265376564643366303831393562636439380a0a436c69636b20746f207369676e20696e20616e642061636365707420746865204f70656e536561205465726d73206f662053657276696365202868747470733a2f2f6f70656e7365612e696f2f746f732920616e64205072697661637920506f6c696379202868747470733a2f2f6f70656e7365612e696f2f70726976616379292e0a0a5552493a2068747470733a2f2f6f70656e7365612e696f2f70726f66696c650a56657273696f6e3a20310a436861696e2049443a2031313135353131310a4e6f6e63653a206a346d756d696733316b626133636871723434656a6e696961650a4973737565642041743a20323032362d30312d32365431353a35333a30382e3530345a',
        'hex': true,
        'method': 'ethereumSignMessage',
      };

      // Act
      AApiMethodDto actualApiMethodDto = ApiMethodParser.fromWsPayloadJson(actualPayloadJson);

      // Assert
      AApiMethodDto expectedApiMethodDto = EthSignMsg(
        path: "m/44'/60'/0'/0/1",
        message:
            '6f70656e7365612e696f2077616e747320796f7520746f207369676e20696e207769746820796f7572206163636f756e743a0a3078333864653833343331383437366463646263616539653265376564643366303831393562636439380a0a436c69636b20746f207369676e20696e20616e642061636365707420746865204f70656e536561205465726d73206f662053657276696365202868747470733a2f2f6f70656e7365612e696f2f746f732920616e64205072697661637920506f6c696379202868747470733a2f2f6f70656e7365612e696f2f70726976616379292e0a0a5552493a2068747470733a2f2f6f70656e7365612e696f2f70726f66696c650a56657273696f6e3a20310a436861696e2049443a2031313135353131310a4e6f6e63653a206a346d756d696733316b626133636871723434656a6e696961650a4973737565642041743a20323032362d30312d32365431353a35333a30382e3530345a',
        hex: true,
      );

      expect(actualApiMethodDto, expectedApiMethodDto);
    });

    test('Should [throw ArgumentError] when method is unknown', () {
      // Arrange
      Map<String, dynamic> actualPayloadJson = <String, dynamic>{
        'method': 'unknownMethod',
      };

      // Act
      void actualCall() => ApiMethodParser.fromWsPayloadJson(actualPayloadJson);

      // Assert
      expect(actualCall, throwsArgumentError);
    });
  });
}
