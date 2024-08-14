import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/trezor_communication_notifier.dart';

void main() {
  initLocator();
  TrezorCommunicationNotifier actualTrezorCommunicationNotifier = globalLocator<TrezorCommunicationNotifier>();

  group('Tests of ProtobufController.getResponseBuffer()', () {
    test('Should [return Features buffer] with [FILLED sessionId], if input starts with 0000 and [sessionId EXISTS] (Initialize -> Features)', () async {
      // Arrange
      // Buffer for [Initialize]
      String actualInputBuffer = '0000000000070a050102030405';

      // Act
      String actualOutputBuffer = await actualTrezorCommunicationNotifier.getResponseBuffer(actualInputBuffer);

      // Assert
      // Buffer for [Features]
      String expectedOutputBuffer =
          '0011000000f00a097472657a6f722e696f1002180820013218333535433831373531304330454142463246313437313435380140014a05656e2d555352094d79205472657a6f7260016a14c7832c39ab3c2a9c46544c57d1a8980583609f47800101980100a00100aa010154ca0108454d554c41544f52d80100e00100e80100f00101f00102f00103f00104f00105f00107f00109f0010bf0010cf0010df0010ef0010ff00110f00111f00112f00113f0010af00106f801008002018802009002009a02050102030405a00200a80200b002c0cf24b80200c00200c80200d00202d80200e2020454325431f802f0018003f001900301';

      expect(actualOutputBuffer, expectedOutputBuffer);
    });

    test('Should [return Features buffer] with [RANDOM sessionId] if input starts with 0000 [sessionId NOT EXISTS] (Initialize -> Features)', () async {
      // Arrange
      // Buffer for [Initialize]
      String actualInputBuffer = '000000000000';

      // Act
      // The random sessionId affects the middle part of the buffer, therefore the second part of the buffer is expected not to be equal.
      String actualOutputBuffer = await actualTrezorCommunicationNotifier.getResponseBuffer(actualInputBuffer);
      String actualOutputBufferPart1 = actualOutputBuffer.substring(0, 394); // expected equal
      String actualOutputBufferPart2 = actualOutputBuffer.substring(395, 457); // expected not equal (random sessionId)
      String actualOutputBufferPart3 = actualOutputBuffer.substring(458, actualOutputBuffer.length); // expected equal

      // Assert
      // Buffer for [Features]
      String expectedOutputBuffer =
          '00110000010b0a097472657a6f722e696f1002180820013218333535433831373531304330454142463246313437313435380140014a05656e2d555352094d79205472657a6f7260016a14c7832c39ab3c2a9c46544c57d1a8980583609f47800101980100a00100aa010154ca0108454d554c41544f52d80100e00100e80100f00101f00102f00103f00104f00105f00107f00109f0010bf0010cf0010df0010ef0010ff00110f00111f00112f00113f0010af00106f801008002018802009002009a02203b5803f0b2a5a4dd6de7f846a8e087ba4e41ceeb01f3f6ccef30db4369638084a00200a80200b002c0cf24b80200c00200c80200d00202d80200e2020454325431f802f0018003f001900301';
      String expectedBufferPart1 = expectedOutputBuffer.substring(0, 394);
      String expectedBufferPart2 = expectedOutputBuffer.substring(395, 457);
      String expectedBufferPart3 = expectedOutputBuffer.substring(458, expectedOutputBuffer.length);

      expect(actualOutputBufferPart1, expectedBufferPart1);
      expect(actualOutputBufferPart2, isNot(equals(expectedBufferPart2)));
      expect(actualOutputBufferPart3, expectedBufferPart3);
    });

    test('Should [return Address buffer] if input starts with 001d (GetAddress -> Address)', () async {
      // Arrange
      String actualInputBuffer = '001d00000000';

      // Act
      String actualOutputBuffer = await actualTrezorCommunicationNotifier.getResponseBuffer(actualInputBuffer);

      // Assert
      String expectedOutputBuffer = '001e000000020a00';

      expect(actualOutputBuffer, expectedOutputBuffer);
    });

    test('Should [return Features buffer] with [EMPTY sessionId] if input starts with 0037 (GetFeatures -> Features)', () async {
      // Arrange
      // Buffer for [GetFeatures]
      String actualInputBuffer = '003700000000';

      // Act
      String actualOutputBuffer = await actualTrezorCommunicationNotifier.getResponseBuffer(actualInputBuffer);

      // Assert
      // Buffer for [Features]
      String expectedOutputBuffer =
          '0011000000e80a097472657a6f722e696f1002180820013218333535433831373531304330454142463246313437313435380140014a05656e2d555352094d79205472657a6f7260016a14c7832c39ab3c2a9c46544c57d1a8980583609f47800101980100a00100aa010154ca0108454d554c41544f52d80100e00100e80100f00101f00102f00103f00104f00105f00107f00109f0010bf0010cf0010df0010ef0010ff00110f00111f00112f00113f0010af00106f80100800201880200900200a00200a80200b002c0cf24b80200c00200c80200d00202d80200e2020454325431f802f0018003f001900301';

      expect(actualOutputBuffer, expectedOutputBuffer);
    });
  });
}
