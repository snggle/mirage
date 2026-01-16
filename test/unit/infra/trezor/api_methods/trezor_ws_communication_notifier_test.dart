import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_ws_communication_notifier.dart';

void main() {
  initLocator();
  TrezorWsCommunicationNotifier actualTrezorWsCommunicationNotifier = globalLocator<TrezorWsCommunicationNotifier>();

  group('Tests of ProtobufController.getResponsePayload()', () {
    test('Should throw [ArgumentError] if [method] unknown', () async {
      // Arrange
      Map<String, dynamic> actualInputPayload = <String, dynamic>{
        'method': 'aaa',
      };

      // Assert
      expect(
        () async => actualTrezorWsCommunicationNotifier.getResponsePayload(actualInputPayload),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
