import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/trezor_public_key_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/trezor_tx_data_supply.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/trezor_ask_to_wait_response.dart';

void main() {
  group('Tests of TrezorPublicKeyRequest.askForSupplementaryInfo()', () {
    test('Should [return TrezorAskToWaitResponse]', () async {
      // Arrange
      TrezorPublicKeyRequest trezorPublicKeyRequest = TrezorPublicKeyRequest(
        waitingAgreedBool: false,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
      );

      // Act
      ATrezorOutboundResponse actualTrezorOutboundResponse = trezorPublicKeyRequest.askForSupplementaryInfo();

      // Assert
      TrezorAskToWaitResponse expectedTrezorOutboundResponse = TrezorAskToWaitResponse.publicKey();

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
