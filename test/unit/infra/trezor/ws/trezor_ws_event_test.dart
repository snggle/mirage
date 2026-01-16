import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/infra/trezor/api_methods/dto/inbound/get_public_key.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_public_key_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/trezor_public_key_response.dart';
import 'package:mirage/infra/trezor/ws/trezor_ws_event.dart';

// ignore_for_file: cascade_invocations
void main() {
  group('Tests of TrezorWsEvent.resolve() method', () {
    test('Should [return ATrezorInteractiveRequest]', () async {
      // Arrange
      TrezorWsEvent actualTrezorWsEvent = TrezorWsEvent(
        TrezorPublicKeyRequest.fromDto(
          GetPublicKey.fromJson(
            const <String, dynamic>{
              'path': "m/44'/60'/0'/0",
              'coin': 'ETH',
              'method': 'getPublicKey',
            },
          ),
        ),
      );

      TrezorPublicKeyResponse actualTrezorPublicKeyResponse = TrezorPublicKeyResponse(
        depth: 5,
        fingerprint: 1881575369,
        // @formatter:off
        chainCode: 'aa',
        publicKey: 'aa',
        // @formatter:on
        xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
        stringDerivationPath: '',
        numericDerivationPath: const <int>[],
      );

      // Act
      actualTrezorWsEvent.resolve(actualTrezorPublicKeyResponse);
      ATrezorOutboundResponse actualTrezorOutboundResponse = await actualTrezorWsEvent.future;

      // Assert
      ATrezorOutboundResponse expectedTrezorOutboundResponse = TrezorPublicKeyResponse(
        depth: 5,
        fingerprint: 1881575369,
        // @formatter:off
        chainCode: 'aa',
        publicKey: 'aa',
        // @formatter:on
        xpub: 'xpub6EMiSgKByUhGbZKZJZNMwWxH43B4xgacikQjWiqhXwFH6QngswJxEZ8YwDEusBXL9wZFuPe6Va989JtmtDWAPrBdXhfcerNCNFeTsjdnq8s',
        stringDerivationPath: '',
        numericDerivationPath: const <int>[],
      );

      expect(actualTrezorOutboundResponse, expectedTrezorOutboundResponse);
    });
  });

  group('Tests of TrezorWsEvent.resolve() method', () {
    test('Should [return ATrezorInteractiveRequest]', () async {
      // Arrange
      TrezorWsEvent actualTrezorWsEvent = TrezorWsEvent(
        TrezorPublicKeyRequest.fromDto(
          GetPublicKey.fromJson(
            const <String, dynamic>{
              'path': "m/44'/60'/0'/0",
              'coin': 'ETH',
              'method': 'getPublicKey',
            },
          ),
        ),
      );

      // Act
      actualTrezorWsEvent.reject('Operation canceled');

      // Assert
      expect(
        () async => actualTrezorWsEvent.future,
        throwsA(anything),
      );
    });
  });
}
