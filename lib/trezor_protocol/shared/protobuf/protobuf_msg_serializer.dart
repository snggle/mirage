import 'dart:typed_data';

import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages.pbenum.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/protobuf_msg_mapper.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

/// Mirage receives buffers from connect.trezor.io in the http POST requests with "call" path parameter.
/// The buffer structure looks as follows:
/// The first 2 bytes represent the numerical message type in BE uint16_t format.
/// The next 4 bytes represent the message size in BE uint32_t.
/// The rest of the bytes are the actual message contents in uint8_t format, that can be decoded with protobuf.

/// Example: 001d0000002108ac80808008088180808008088080808008080008001207546573746e6574280000000000000000000000000000000000000000000000
/// Message type => 00 1d => 29 => MessageType_GetAddress (the message numbers are defined in messages.proto)
/// Message size => 00 00 00 21 => 33 => The message consists of 33 bytes
/// Actual message contents => 08 ac 80 80 80 08 08 81 80 80 80 08 08 80 80 80 80 08 08 00 08 00 12 07 54 65 73 74 6e 65 74 28 00
/// Deserialized message:
/// GetAddress(
///   addressN: <int>[2147483692, 2147483649, 2147483648, 0, 0],
///   coinName: 'Testnet',
///   scriptType: InputScriptType.SPENDADDRESS,
/// );

/// NOTE: Similar description for the buffer format can be found in the Trezor Emulator repository:
/// https://github.com/trezor/trezor-firmware/blob/0fbfda7762eedf6b46092b08b1e816ac7625b9e7/common/protob/protocol.md#L4
/// However, this format is slightly different, because it includes the communication with Trezor Bridge via UDP.
/// Since the Trezor Bridge is integrated in Mirage, there is no need for magic constants and 64 bytes chunks.
class ProtobufMsgSerializer {
  static protobuf.GeneratedMessage deserialize(String buffer) {
    Uint8List inputBytes = BytesUtils.convertHexToBytes(buffer);
    Uint8List msgContents = inputBytes.sublist(6, 6 + _getMsgSize(buffer));
    try {
      MessageType? messageType = MessageType.valueOf(_getMsgType(buffer));
      return ProtobufMsgMapper.getMsgFromType(messageType!, msgContents);
    } catch (e) {
      throw ArgumentError('Could not interpret bytes: $buffer');
    }
  }

  static String serialize(protobuf.GeneratedMessage protobufMsg) {
    int msgType = ProtobufMsgMapper.getMsgTypeNumber(protobufMsg);
    Uint8List msgBuffer = protobufMsg.writeToBuffer();

    int msgSize = msgBuffer.length;
    Uint8List msgTypeBytes = BytesUtils.convertIntToBytes(msgType, 2);
    Uint8List msgSizeBytes = BytesUtils.convertIntToBytes(msgSize, 4);

    Uint8List mergedBytes = BytesUtils.mergeUint8Lists(<Uint8List>[msgTypeBytes, msgSizeBytes, msgBuffer]);

    String buffer = BytesUtils.convertBytesToHex(mergedBytes);
    return buffer;
  }

  static int _getMsgType(String inputBuffer) => BytesUtils.convertHexToInt(inputBuffer.substring(0, 4));

  static int _getMsgSize(String inputBuffer) => BytesUtils.convertHexToInt(inputBuffer.substring(4, 12));
}
