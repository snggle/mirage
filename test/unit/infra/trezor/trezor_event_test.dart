import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_public_key_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';
import 'package:mirage/infra/trezor/trezor_event.dart';

// ignore_for_file: cascade_invocations
void main() {
  group('Tests of TrezorEvent.resolve() method', () {
    test('Should [return ATrezorInteractiveRequest]', () async {
      // Arrange
      TrezorEvent actualTrezorEvent = TrezorEvent(
        TrezorPublicKeyRequest(
          derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        ),
      );

      TrezorPublicKeyResponse actualTrezorPublicKeyResponse = TrezorPublicKeyResponse(
        depth: 5,
        fingerprint: 1881575369,
        // @formatter:off
        chainCode: const <int>[26, 71, 127, 250, 21, 9, 64, 23, 141, 109, 147, 72, 253, 186, 221, 234, 205, 101, 74, 26, 15, 192, 247, 255, 7, 222, 59, 86, 93, 189, 166, 49],
        publicKey: const <int>[2, 64, 231, 236, 178, 54, 76, 97, 149, 170, 107, 26, 191, 232, 221, 95, 1, 170, 89, 4, 98, 110, 43, 85, 23, 120, 29, 151, 255, 216, 205, 77, 143],
        // @formatter:on
        xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
      );

      // Act
      actualTrezorEvent.resolve(actualTrezorPublicKeyResponse);
      ATrezorAwaitedResponse actualTrezorAwaitedResponse = await actualTrezorEvent.future;

      // Assert
      ATrezorAwaitedResponse expectedTrezorAwaitedResponse = TrezorPublicKeyResponse(
        depth: 5,
        fingerprint: 1881575369,
        // @formatter:off
        chainCode: const <int>[26, 71, 127, 250, 21, 9, 64, 23, 141, 109, 147, 72, 253, 186, 221, 234, 205, 101, 74, 26, 15, 192, 247, 255, 7, 222, 59, 86, 93, 189, 166, 49],
        publicKey: const <int>[2, 64, 231, 236, 178, 54, 76, 97, 149, 170, 107, 26, 191, 232, 221, 95, 1, 170, 89, 4, 98, 110, 43, 85, 23, 120, 29, 151, 255, 216, 205, 77, 143],
        // @formatter:on
        xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
      );

      expect(actualTrezorAwaitedResponse, expectedTrezorAwaitedResponse);
    });
  });

  group('Tests of TrezorEvent.resolve() method', () {
    test('Should [return ATrezorInteractiveRequest]', () async {
      // Arrange
      TrezorEvent actualTrezorEvent = TrezorEvent(
        TrezorPublicKeyRequest(
          derivationPath: const <int>[2147483692, 2147483708, 2147483648, 0, 0],
        ),
      );

      // Act
      actualTrezorEvent.reject('Operation canceled');

      // Assert
      expect(
        () async => actualTrezorEvent.future,
        throwsA(anything),
      );
    });
  });
}
