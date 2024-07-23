import 'dart:typed_data';

import 'package:cryptography_utils/cryptography_utils.dart' as cryptography_utils;
import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/trezor_eip1559_signature_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/trezor_eip1559_signature_response.dart';

void main() {
  group('Tests of TrezorEIP1559SignatureRequest.getResponseFromCborPayload()', () {
    test('Should [return TrezorEIP1559SignatureRequest]', () async {
      // Arrange
      TrezorEIP1559SignatureRequest actualTrezorEIP1559SignatureRequest = TrezorEIP1559SignatureRequest(
        waitingAgreedBool: true,
        ethereumEIP1559Transaction: cryptography_utils.EthereumEIP1559Transaction(
          chainId: BigInt.from(11155111),
          nonce: BigInt.from(45),
          maxPriorityFeePerGas: BigInt.from(1500000000),
          maxFeePerGas: BigInt.from(36232466683),
          gasLimit: BigInt.from(21000),
          to: '479b2970f03f9021cff00b6e5807ba544ea351f8',
          value: BigInt.from(10000000000000000),
          data: Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]),
          accessList: const <cryptography_utils.AccessListBytesItem>[],
        ),
        dataLength: 16,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        token: 'Sepolia tETH',
      );

      String actualCborPayload =
          '830158202aa9c11e25c21aec96045bd5895d8389a36edc9d3db7d4ea3092628208c6428658203d91e55263e2638ee22a08f65d443f1f6e5266ae2347f2ba7d451c05373d8681';

      // Act
      ATrezorOutboundResponse actualTrezorOutboundResponse = await actualTrezorEIP1559SignatureRequest.getResponseFromCborPayload(actualCborPayload);

      // Assert
      TrezorEIP1559SignatureResponse expectedTrezorOutboundResponse = TrezorEIP1559SignatureResponse(
        signatureV: 1,
        // @formatter:off
        signatureR: const <int>[42, 169, 193, 30, 37, 194, 26, 236, 150, 4, 91, 213, 137, 93, 131, 137, 163, 110, 220, 157, 61, 183, 212, 234, 48, 146, 98, 130, 8, 198, 66, 134],
        signatureS: const <int>[61, 145, 229, 82, 99, 226, 99, 142, 226, 42, 8, 246, 93, 68, 63, 31, 110, 82, 102, 174, 35, 71, 242, 186, 125, 69, 28, 5, 55, 61, 134, 129],
        // @formatter:on
      );

      expect(actualTrezorOutboundResponse, expectedTrezorOutboundResponse);
    });
  });
}
