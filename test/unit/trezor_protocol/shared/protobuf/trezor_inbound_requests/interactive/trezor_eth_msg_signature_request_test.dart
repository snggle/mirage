import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/trezor_eth_msg_signature_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/trezor_eth_msg_signature_response.dart';

void main() {
  group('Tests of TrezorEthMsgSignatureRequest.getResponseFromCborPayload()', () {
    test('Should [return TrezorEthMsgSignatureRequest]', () async {
      // Arrange
      TrezorEthMsgSignatureRequest actualTrezorEthMsgSignatureRequest = TrezorEthMsgSignatureRequest(
        waitingAgreedBool: false,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        // @formatter:off
        message: const <int>[87, 101, 108, 99, 111, 109, 101, 32, 116, 111, 32, 79, 112, 101, 110, 83, 101, 97, 33, 10, 10, 67, 108, 105, 99, 107, 32, 116, 111, 32, 115, 105, 103, 110, 32, 105, 110, 32, 97, 110, 100, 32, 97, 99, 99, 101, 112, 116, 32, 116, 104, 101, 32, 79, 112, 101, 110, 83, 101, 97, 32, 84, 101, 114, 109, 115, 32, 111, 102, 32, 83, 101, 114, 118, 105, 99, 101, 32, 40, 104, 116, 116, 112, 115, 58, 47, 47, 111, 112, 101, 110, 115, 101, 97, 46, 105, 111, 47, 116, 111, 115, 41, 32, 97, 110, 100, 32, 80, 114, 105, 118, 97, 99, 121, 32, 80, 111, 108, 105, 99, 121, 32, 40, 104, 116, 116, 112, 115, 58, 47, 47, 111, 112, 101, 110, 115, 101, 97, 46, 105, 111, 47, 112, 114, 105, 118, 97, 99, 121, 41, 46, 10, 10, 84, 104, 105, 115, 32, 114, 101, 113, 117, 101, 115, 116, 32, 119, 105, 108, 108, 32, 110, 111, 116, 32, 116, 114, 105, 103, 103, 101, 114, 32, 97, 32, 98, 108, 111, 99, 107, 99, 104, 97, 105, 110, 32, 116, 114, 97, 110, 115, 97, 99, 116, 105, 111, 110, 32, 111, 114, 32, 99, 111, 115, 116, 32, 97, 110, 121, 32, 103, 97, 115, 32, 102, 101, 101, 115, 46, 10, 10, 87, 97, 108, 108, 101, 116, 32, 97, 100, 100, 114, 101, 115, 115, 58, 10, 48, 120, 53, 51, 98, 102, 48, 97, 49, 56, 55, 53, 52, 56, 55, 51, 97, 56, 49, 48, 50, 54, 50, 53, 100, 56, 50, 50, 53, 97, 102, 54, 97, 49, 53, 97, 52, 51, 52, 50, 51, 99, 10, 10, 78, 111, 110, 99, 101, 58, 10, 53, 56, 51, 57, 57, 48, 48, 99, 45, 51, 102, 99, 49, 45, 52, 49, 97, 100, 45, 57, 97, 100, 54, 45, 55, 52, 54, 102, 100, 102, 48, 57, 52, 99, 50, 97],
        // @formatter:on
      );

      String actualCborPayload =
          '82782a30783533426630413138373534383733413831303236323544383232354146366131356134333432334358419c11bff12d9f8a376997314541e2c462ede39947936ef310628ce6848e4b02de71211a15716a0f6c426177509b299f5ca6f0dbd73ec0efbb5ddd3b58f2f6b5331c';

      // Act
      ATrezorOutboundResponse actualTrezorOutboundResponse = await actualTrezorEthMsgSignatureRequest.getResponseFromCborPayload(actualCborPayload);

      // Assert
      TrezorEthMsgSignatureResponse expectedTrezorOutboundResponse = TrezorEthMsgSignatureResponse(
        address: '0x53Bf0A18754873A8102625D8225AF6a15a43423C',
        // @formatter:off
          signature: const <int>[156, 17, 191, 241, 45, 159, 138, 55, 105, 151, 49, 69, 65, 226, 196, 98, 237, 227, 153, 71, 147, 110, 243, 16, 98, 140, 230, 132, 142, 75, 2, 222, 113, 33, 26, 21, 113, 106, 15, 108, 66, 97, 119, 80, 155, 41, 159, 92, 166, 240, 219, 215, 62, 192, 239, 187, 93, 221, 59, 88, 242, 246, 181, 51, 28],
        // @formatter:on
      );

      expect(actualTrezorOutboundResponse, expectedTrezorOutboundResponse);
    });
  });
}
