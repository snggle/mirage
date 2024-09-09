import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_derived_public_key_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';
import 'package:mirage/infra/trezor/trezor_communication_notifier.dart';

import '../../../../../../mocks/mock_locator.dart';
import '../../../../../../utils/test_utils.dart';

Future<void> main() async {
  await initMockLocator();

  group('Tests of TrezorDerivedPublicKeyRequest.getResponse()', () {
    setUp(() async {
      await TestUtils.initWithTestPubkey();
      await globalLocator<TrezorCommunicationNotifier>().init();
    });

    tearDown(TestUtils.deleteMockedPublicKey);

    test('Should [return TrezorPublicKeyResponse] containing derived public key info', () async {
      // Arrange
      TrezorDerivedPublicKeyRequest actualTrezorDerivedPublicKeyRequest = TrezorDerivedPublicKeyRequest(
        waitingAgreedBool: false,
        derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
      );

      // Act
      ATrezorOutboundResponse actualTrezorOutboundResponse = actualTrezorDerivedPublicKeyRequest.getResponse();

      // Assert
      ATrezorOutboundResponse expectedTrezorOutboundResponse = TrezorPublicKeyResponse(
        depth: 5,
        fingerprint: 2382068266,
        // @formatter:off
        chainCode: const <int>[84, 183, 128, 99, 7, 193, 8, 47, 107, 187, 71, 153, 160, 209, 69, 66, 107, 30, 38, 113, 151, 155, 57, 192, 197, 144, 179, 161, 119, 126, 146, 102],
        publicKey: const <int>[2, 91, 39, 90, 216, 36, 82, 122, 218, 143, 118, 6, 6, 108, 41, 58, 115, 85, 242, 184, 125, 224, 2, 18, 14, 2, 27, 166, 54, 0, 140, 3, 138],
        // @formatter:on
        xpub: 'xpub6GTZvMtLoeTYGYuLUMGbDiKnDQr3HvpTtbWjAXroWEdDfjRtHNPJy1E2fpSyJPCPjNLf8S61P7eTAHFGcWDzUqTmAiPs5nSPtzoLCEyAtiE',
      );

      expect(actualTrezorOutboundResponse, expectedTrezorOutboundResponse);
    });
  });
}
