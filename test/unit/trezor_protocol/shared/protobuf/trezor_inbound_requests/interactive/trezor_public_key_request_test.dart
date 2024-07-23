import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/interactive/trezor_public_key_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';

void main() {
  group('Tests of TrezorPublicKeyRequest.getResponseFromCborPayload()', () {
    test('Should [return TrezorPublicKeyResponse]', () async {
      // Arrange
      TrezorPublicKeyRequest actualTrezorPublicKeyRequest = TrezorPublicKeyRequest(
        waitingAgreedBool: true,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
      );

      String actualCborPayload =
          '85041a70268fc958201a477ffa150940178d6d9348fdbaddeacd654a1a0fc0f7ff07de3b565dbda63158210240e7ecb2364c6195aa6b1abfe8dd5f01aa5904626e2b5517781d97ffd8cd4d8f786f7870756236454d6953674b4279556847625a4b5a4a5a4e4d775778483433423478676163696b516a576971685877464836516e6773774a78455a3859774445757342584c39775a467550653656613938394a746d74445741507242645868666365724e434e466554736a646e713873';

      // Act
      ATrezorOutboundResponse actualTrezorOutboundResponse = await actualTrezorPublicKeyRequest.getResponseFromCborPayload(actualCborPayload);

      // Assert
      TrezorPublicKeyResponse expectedTrezorOutboundResponse = TrezorPublicKeyResponse(
        depth: 4,
        fingerprint: 1881575369,
        // @formatter:off
        chainCode: const <int>[26, 71, 127, 250, 21, 9, 64, 23, 141, 109, 147, 72, 253, 186, 221, 234, 205, 101, 74, 26, 15, 192, 247, 255, 7, 222, 59, 86, 93, 189, 166, 49],
        publicKey: const <int>[2, 64, 231, 236, 178, 54, 76, 97, 149, 170, 107, 26, 191, 232, 221, 95, 1, 170, 89, 4, 98, 110, 43, 85, 23, 120, 29, 151, 255, 216, 205, 77, 143],
        // @formatter:on
        xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
      );

      expect(actualTrezorOutboundResponse, expectedTrezorOutboundResponse);
    });
  });
}
