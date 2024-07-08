import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/trezor_eth_msg_signature_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/trezor_public_key_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/trezor_tx_data_supply.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/trezor_ask_to_wait_response.dart';

void main() {
  group('Tests of TrezorEthMsgSignatureRequest.askForSupplementaryInfo()', () {
    test('Should [return TrezorAskToWaitResponse]', () async {
      // Arrange
      TrezorEthMsgSignatureRequest trezorEthMsgSignatureRequest = TrezorEthMsgSignatureRequest(
        waitingAgreedBool: false,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        // @formatter:off
        message: const <int>[87, 101, 108, 99, 111, 109, 101, 32, 116, 111, 32, 79, 112, 101, 110, 83, 101, 97, 33, 10, 10, 67, 108, 105, 99, 107, 32, 116, 111, 32, 115, 105, 103, 110, 32, 105, 110, 32, 97, 110, 100, 32, 97, 99, 99, 101, 112, 116, 32, 116, 104, 101, 32, 79, 112, 101, 110, 83, 101, 97, 32, 84, 101, 114, 109, 115, 32, 111, 102, 32, 83, 101, 114, 118, 105, 99, 101, 32, 40, 104, 116, 116, 112, 115, 58, 47, 47, 111, 112, 101, 110, 115, 101, 97, 46, 105, 111, 47, 116, 111, 115, 41, 32, 97, 110, 100, 32, 80, 114, 105, 118, 97, 99, 121, 32, 80, 111, 108, 105, 99, 121, 32, 40, 104, 116, 116, 112, 115, 58, 47, 47, 111, 112, 101, 110, 115, 101, 97, 46, 105, 111, 47, 112, 114, 105, 118, 97, 99, 121, 41, 46, 10, 10, 84, 104, 105, 115, 32, 114, 101, 113, 117, 101, 115, 116, 32, 119, 105, 108, 108, 32, 110, 111, 116, 32, 116, 114, 105, 103, 103, 101, 114, 32, 97, 32, 98, 108, 111, 99, 107, 99, 104, 97, 105, 110, 32, 116, 114, 97, 110, 115, 97, 99, 116, 105, 111, 110, 32, 111, 114, 32, 99, 111, 115, 116, 32, 97, 110, 121, 32, 103, 97, 115, 32, 102, 101, 101, 115, 46, 10, 10, 87, 97, 108, 108, 101, 116, 32, 97, 100, 100, 114, 101, 115, 115, 58, 10, 48, 120, 53, 51, 98, 102, 48, 97, 49, 56, 55, 53, 52, 56, 55, 51, 97, 56, 49, 48, 50, 54, 50, 53, 100, 56, 50, 50, 53, 97, 102, 54, 97, 49, 53, 97, 52, 51, 52, 50, 51, 99, 10, 10, 78, 111, 110, 99, 101, 58, 10, 53, 56, 51, 57, 57, 48, 48, 99, 45, 51, 102, 99, 49, 45, 52, 49, 97, 100, 45, 57, 97, 100, 54, 45, 55, 52, 54, 102, 100, 102, 48, 57, 52, 99, 50, 97],
        // @formatter:on
      );

      // Act
      ATrezorOutboundResponse actualTrezorOutboundResponse = trezorEthMsgSignatureRequest.askForSupplementaryInfo();

      // Assert
      TrezorAskToWaitResponse expectedTrezorOutboundResponse = TrezorAskToWaitResponse.ethMsgSignature();

      expect(actualTrezorOutboundResponse, expectedTrezorOutboundResponse);
    });
  });

  group('Tests of TrezorPublicKeyRequest.fillWithAnotherRequest()', () {
    test('Should change [waitingAgreedBool to true] when given TrezorWaitForResponseAgreement', () async {
      // Arrange
      TrezorPublicKeyRequest actualTrezorPublicKeyRequest = TrezorPublicKeyRequest(
        waitingAgreedBool: false,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
      );

      TrezorTxDataSupply trezorTxDataSupply = TrezorTxDataSupply(dataChunk: Uint8List.fromList(<int>[9, 10, 11, 12, 13, 14, 15, 16]));

      // Act
      actualTrezorPublicKeyRequest.fillWithAnotherRequest(trezorTxDataSupply);

      // Assert
      TrezorPublicKeyRequest expectedTrezorPublicKeyRequest = TrezorPublicKeyRequest(
        waitingAgreedBool: false,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
      );

      expect(actualTrezorPublicKeyRequest, expectedTrezorPublicKeyRequest);
    });
  });

  group('Tests of TrezorPublicKeyRequest.requestReadyBool()', () {
    test('Should [return false] if [waitingAgreedBool == false]', () async {
      // Arrange
      TrezorPublicKeyRequest actualTrezorPublicKeyRequest = TrezorPublicKeyRequest(
        waitingAgreedBool: false,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
      );

      // Act
      bool actualRequestReadyBool = actualTrezorPublicKeyRequest.requestReadyBool;

      // Assert
      bool expectedRequestReadyBool = false;

      expect(actualRequestReadyBool, expectedRequestReadyBool);
    });

    test('Should [return true] if [waitingAgreedBool == true]', () async {
      // Arrange
      TrezorPublicKeyRequest actualTrezorPublicKeyRequest = TrezorPublicKeyRequest(
        waitingAgreedBool: true,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
      );

      // Act
      bool actualRequestReadyBool = actualTrezorPublicKeyRequest.requestReadyBool;

      // Assert
      bool expectedRequestReadyBool = true;

      expect(actualRequestReadyBool, expectedRequestReadyBool);
    });
  });
}
