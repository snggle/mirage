import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/protobuf_msg_serializer.dart';
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

    test('Should [return EthereumTxRequest] with [dataLength = 512] if inputMsg is EthereumSignTxEIP1559 with dataLength = 1536', () async {
      // Arrange
      // @formatter:off
      // Buffer for [EthereumSignTxEIP1559 with dataLength = 1536]
      String actualInputBuffer = '01c4000004064280080101010101010101020202020202020203030303030303030404040404040404050505050505050506060606060606060707070707070707080808080808080809090909090909090a0a0a0a0a0a0a0a0b0b0b0b0b0b0b0b0c0c0c0c0c0c0c0c0d0d0d0d0d0d0d0d0e0e0e0e0e0e0e0e0f0f0f0f0f0f0f0f10101010101010101111111111111111121212121212121213131313131313131414141414141414151515151515151516161616161616161717171717171717181818181818181819191919191919191a1a1a1a1a1a1a1a1b1b1b1b1b1b1b1b1c1c1c1c1c1c1c1c1d1d1d1d1d1d1d1d1e1e1e1e1e1e1e1e1f1f1f1f1f1f1f1f20202020202020202121212121212121222222222222222223232323232323232424242424242424252525252525252526262626262626262727272727272727282828282828282829292929292929292a2a2a2a2a2a2a2a2b2b2b2b2b2b2b2b2c2c2c2c2c2c2c2c2d2d2d2d2d2d2d2d2e2e2e2e2e2e2e2e2f2f2f2f2f2f2f2f30303030303030303131313131313131323232323232323233333333333333333434343434343434353535353535353536363636363636363737373737373737383838383838383839393939393939393a3a3a3a3a3a3a3a3b3b3b3b3b3b3b3b3c3c3c3c3c3c3c3c3d3d3d3d3d3d3d3d3e3e3e3e3e3e3e3e3f3f3f3f3f3f3f3f40404040404040404141414141414141424242424242424243434343434343434444444444444444454545454545454546464646464646464747474747474747484848484848484849494949494949494a4a4a4a4a4a4a4a4b4b4b4b4b4b4b4b4c4c4c4c4c4c4c4c4d4d4d4d4d4d4d4d4e4e4e4e4e4e4e4e4f4f4f4f4f4f4f4f50505050505050505151515151515151525252525252525253535353535353535454545454545454555555555555555556565656565656565757575757575757585858585858585859595959595959595a5a5a5a5a5a5a5a5b5b5b5b5b5b5b5b5c5c5c5c5c5c5c5c5d5d5d5d5d5d5d5d5e5e5e5e5e5e5e5e5f5f5f5f5f5f5f5f60606060606060606161616161616161626262626262626263636363636363636464646464646464656565656565656566666666666666666767676767676767686868686868686869696969696969696a6a6a6a6a6a6a6a6b6b6b6b6b6b6b6b6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f70707070707070707171717171717171727272727272727273737373737373737474747474747474757575757575757576767676767676767777777777777777787878787878787879797979797979797a7a7a7a7a7a7a7a7b7b7b7b7b7b7b7b7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f808080808080808048800c';
      // @formatter:on

      // Act
      String actualResponseBuffer = await actualTrezorCommunicationNotifier.getResponseBuffer(actualInputBuffer);

      // Assert
      EthereumTxRequest expectedMsg = EthereumTxRequest(dataLength: 512);
      String expectedResponseBuffer = ProtobufMsgSerializer.serialize(expectedMsg);

      expect(actualResponseBuffer, expectedResponseBuffer);
    });
  });
}
