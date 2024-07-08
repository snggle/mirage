import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/trezor_protocol/controllers/trezor_communication_controller.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-common.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/protobuf_msg_serializer.dart';

void main() {
  initLocator();
  TrezorCommunicationController actualTrezorCommunicationController = globalLocator<TrezorCommunicationController>();

  group('Tests of ProtobufController.handleBuffer()', () {
    test('Should [return Features buffer] with [FILLED sessionId], if input starts with 0000 and [sessionId EXISTS] (Initialize -> Features)', () async {
      // Arrange
      // Buffer for [Initialize]
      String actualInputBuffer = '0000000000070a050102030405';

      // Act
      String actualOutputBuffer = await actualTrezorCommunicationController.handleBuffer(actualInputBuffer);

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
      String actualOutputBuffer = await actualTrezorCommunicationController.handleBuffer(actualInputBuffer);
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
      String actualOutputBuffer = await actualTrezorCommunicationController.handleBuffer(actualInputBuffer);

      // Assert
      String expectedOutputBuffer = '001e000000020a00';

      expect(actualOutputBuffer, expectedOutputBuffer);
    });

    test('Should [return Features buffer] with [EMPTY sessionId] if input starts with 0037 (GetFeatures -> Features)', () async {
      // Arrange
      // Buffer for [GetFeatures]
      String actualInputBuffer = '003700000000';

      // Act
      String actualOutputBuffer = await actualTrezorCommunicationController.handleBuffer(actualInputBuffer);

      // Assert
      // Buffer for [Features]
      String expectedOutputBuffer =
          '0011000000e80a097472657a6f722e696f1002180820013218333535433831373531304330454142463246313437313435380140014a05656e2d555352094d79205472657a6f7260016a14c7832c39ab3c2a9c46544c57d1a8980583609f47800101980100a00100aa010154ca0108454d554c41544f52d80100e00100e80100f00101f00102f00103f00104f00105f00107f00109f0010bf0010cf0010df0010ef0010ff00110f00111f00112f00113f0010af00106f80100800201880200900200a00200a80200b002c0cf24b80200c00200c80200d00202d80200e2020454325431f802f0018003f001900301';

      expect(actualOutputBuffer, expectedOutputBuffer);
    });

    test('Should [return ButtonRequest] with [PublicKey type] if inputMsg is GetPublicKey', () async {
      // Arrange
      GetPublicKey actualMsg = GetPublicKey();
      String actualInputBuffer = ProtobufMsgSerializer.serialize(actualMsg);

      // Act
      String actualResponseBuffer = await actualTrezorCommunicationController.handleBuffer(actualInputBuffer);

      // Assert
      ButtonRequest expectedMsg = ButtonRequest(code: ButtonRequest_ButtonRequestType.ButtonRequest_PublicKey);
      String expectedResponseBuffer = ProtobufMsgSerializer.serialize(expectedMsg);

      expect(actualResponseBuffer, expectedResponseBuffer);
    });

    test('Should [return ButtonRequest] with [SignTx type] if inputMsg is EthereumSignMessage', () async {
      // Arrange
      EthereumSignMessage actualMsg = EthereumSignMessage();
      String actualInputBuffer = ProtobufMsgSerializer.serialize(actualMsg);

      // Act
      String actualResponseBuffer = await actualTrezorCommunicationController.handleBuffer(actualInputBuffer);

      // Assert
      ButtonRequest expectedMsg = ButtonRequest(code: ButtonRequest_ButtonRequestType.ButtonRequest_SignTx);
      String expectedResponseBuffer = ProtobufMsgSerializer.serialize(expectedMsg);

      expect(actualResponseBuffer, expectedResponseBuffer);
    });

    test('Should [return ButtonRequest] with [PublicKey type] if inputMsg is EthereumSignTxEIP1559', () async {
      // Arrange
      EthereumSignTxEIP1559 actualMsg = EthereumSignTxEIP1559();
      String actualInputBuffer = ProtobufMsgSerializer.serialize(actualMsg);

      // Act
      String actualResponseBuffer = await actualTrezorCommunicationController.handleBuffer(actualInputBuffer);

      // Assert
      ButtonRequest expectedMsg = ButtonRequest(code: ButtonRequest_ButtonRequestType.ButtonRequest_SignTx);
      String expectedResponseBuffer = ProtobufMsgSerializer.serialize(expectedMsg);

      expect(actualResponseBuffer, expectedResponseBuffer);
    });

    test('Should [return EthereumTxRequest] with [dataLength = 512] if inputMsg is EthereumSignTxEIP1559 with dataLength = 1536', () async {
      // Arrange
      // @formatter:off
      EthereumSignTxEIP1559 actualMsg = EthereumSignTxEIP1559(dataLength: 1536, dataInitialChunk: <int>[1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 20, 20, 21, 21, 21, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 22, 22, 23, 23, 23, 23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 25, 25, 26, 26, 26, 26, 26, 26, 26, 26, 27, 27, 27, 27, 27, 27, 27, 27, 28, 28, 28, 28, 28, 28, 28, 28, 29, 29, 29, 29, 29, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 31, 31, 31, 31, 31, 31, 31, 31, 32, 32, 32, 32, 32, 32, 32, 32, 33, 33, 33, 33, 33, 33, 33, 33, 34, 34, 34, 34, 34, 34, 34, 34, 35, 35, 35, 35, 35, 35, 35, 35, 36, 36, 36, 36, 36, 36, 36, 36, 37, 37, 37, 37, 37, 37, 37, 37, 38, 38, 38, 38, 38, 38, 38, 38, 39, 39, 39, 39, 39, 39, 39, 39, 40, 40, 40, 40, 40, 40, 40, 40, 41, 41, 41, 41, 41, 41, 41, 41, 42, 42, 42, 42, 42, 42, 42, 42, 43, 43, 43, 43, 43, 43, 43, 43, 44, 44, 44, 44, 44, 44, 44, 44, 45, 45, 45, 45, 45, 45, 45, 45, 46, 46, 46, 46, 46, 46, 46, 46, 47, 47, 47, 47, 47, 47, 47, 47, 48, 48, 48, 48, 48, 48, 48, 48, 49, 49, 49, 49, 49, 49, 49, 49, 50, 50, 50, 50, 50, 50, 50, 50, 51, 51, 51, 51, 51, 51, 51, 51, 52, 52, 52, 52, 52, 52, 52, 52, 53, 53, 53, 53, 53, 53, 53, 53, 54, 54, 54, 54, 54, 54, 54, 54, 55, 55, 55, 55, 55, 55, 55, 55, 56, 56, 56, 56, 56, 56, 56, 56, 57, 57, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58, 58, 58, 58, 58, 59, 59, 59, 59, 59, 59, 59, 59, 60, 60, 60, 60, 60, 60, 60, 60, 61, 61, 61, 61, 61, 61, 61, 61, 62, 62, 62, 62, 62, 62, 62, 62, 63, 63, 63, 63, 63, 63, 63, 63, 64, 64, 64, 64, 64, 64, 64, 64, 65, 65, 65, 65, 65, 65, 65, 65, 66, 66, 66, 66, 66, 66, 66, 66, 67, 67, 67, 67, 67, 67, 67, 67, 68, 68, 68, 68, 68, 68, 68, 68, 69, 69, 69, 69, 69, 69, 69, 69, 70, 70, 70, 70, 70, 70, 70, 70, 71, 71, 71, 71, 71, 71, 71, 71, 72, 72, 72, 72, 72, 72, 72, 72, 73, 73, 73, 73, 73, 73, 73, 73, 74, 74, 74, 74, 74, 74, 74, 74, 75, 75, 75, 75, 75, 75, 75, 75, 76, 76, 76, 76, 76, 76, 76, 76, 77, 77, 77, 77, 77, 77, 77, 77, 78, 78, 78, 78, 78, 78, 78, 78, 79, 79, 79, 79, 79, 79, 79, 79, 80, 80, 80, 80, 80, 80, 80, 80, 81, 81, 81, 81, 81, 81, 81, 81, 82, 82, 82, 82, 82, 82, 82, 82, 83, 83, 83, 83, 83, 83, 83, 83, 84, 84, 84, 84, 84, 84, 84, 84, 85, 85, 85, 85, 85, 85, 85, 85, 86, 86, 86, 86, 86, 86, 86, 86, 87, 87, 87, 87, 87, 87, 87, 87, 88, 88, 88, 88, 88, 88, 88, 88, 89, 89, 89, 89, 89, 89, 89, 89, 90, 90, 90, 90, 90, 90, 90, 90, 91, 91, 91, 91, 91, 91, 91, 91, 92, 92, 92, 92, 92, 92, 92, 92, 93, 93, 93, 93, 93, 93, 93, 93, 94, 94, 94, 94, 94, 94, 94, 94, 95, 95, 95, 95, 95, 95, 95, 95, 96, 96, 96, 96, 96, 96, 96, 96, 97, 97, 97, 97, 97, 97, 97, 97, 98, 98, 98, 98, 98, 98, 98, 98, 99, 99, 99, 99, 99, 99, 99, 99, 100, 100, 100, 100, 100, 100, 100, 100, 101, 101, 101, 101, 101, 101, 101, 101, 102, 102, 102, 102, 102, 102, 102, 102, 103, 103, 103, 103, 103, 103, 103, 103, 104, 104, 104, 104, 104, 104, 104, 104, 105, 105, 105, 105, 105, 105, 105, 105, 106, 106, 106, 106, 106, 106, 106, 106, 107, 107, 107, 107, 107, 107, 107, 107, 108, 108, 108, 108, 108, 108, 108, 108, 109, 109, 109, 109, 109, 109, 109, 109, 110, 110, 110, 110, 110, 110, 110, 110, 111, 111, 111, 111, 111, 111, 111, 111, 112, 112, 112, 112, 112, 112, 112, 112, 113, 113, 113, 113, 113, 113, 113, 113, 114, 114, 114, 114, 114, 114, 114, 114, 115, 115, 115, 115, 115, 115, 115, 115, 116, 116, 116, 116, 116, 116, 116, 116, 117, 117, 117, 117, 117, 117, 117, 117, 118, 118, 118, 118, 118, 118, 118, 118, 119, 119, 119, 119, 119, 119, 119, 119, 120, 120, 120, 120, 120, 120, 120, 120, 121, 121, 121, 121, 121, 121, 121, 121, 122, 122, 122, 122, 122, 122, 122, 122, 123, 123, 123, 123, 123, 123, 123, 123, 124, 124, 124, 124, 124, 124, 124, 124, 125, 125, 125, 125, 125, 125, 125, 125, 126, 126, 126, 126, 126, 126, 126, 126, 127, 127, 127, 127, 127, 127, 127, 127, 128, 128, 128, 128, 128, 128, 128, 128]);
      // @formatter:on
      String actualInputBuffer = ProtobufMsgSerializer.serialize(actualMsg);

      // Act
      String actualResponseBuffer = await actualTrezorCommunicationController.handleBuffer(actualInputBuffer);

      // Assert
      EthereumTxRequest expectedMsg = EthereumTxRequest(dataLength: 512);
      String expectedResponseBuffer = ProtobufMsgSerializer.serialize(expectedMsg);

      expect(actualResponseBuffer, expectedResponseBuffer);
    });
  });
}
