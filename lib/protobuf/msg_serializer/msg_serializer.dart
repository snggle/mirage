import 'dart:typed_data';

import 'package:mirage/protobuf/compiled/messages.pb.dart';
import 'package:mirage/protobuf/compiled/messages.pbenum.dart';
import 'package:mirage/protobuf/msg_serializer/msg_mapper.dart';
import 'package:mirage/shared/utils/byte_operations_utils.dart';
import 'package:protobuf/protobuf.dart' as $pb;

// ignore_for_file: avoid_print
class MsgSerializer {
  static $pb.GeneratedMessage deserializeBuffer(String inputBuffer) {
    $pb.GeneratedMessage inputProtoMsg = _unwrapProtoMsg(inputBuffer);
    print('-> RECEIVED MESSAGE:');
    print(MessageType.valueOf(_getMsgType(inputBuffer)));
    print(inputProtoMsg);
    
    return inputProtoMsg;
  }
  
  static String serializeMsg($pb.GeneratedMessage protoMsg) {
    String outputBuffer = _wrapProtoMsg(protoMsg);
    print('-> RETURNED MESSAGE:');
    print(MessageType.valueOf(_getMsgType(outputBuffer)));
    print(protoMsg);

    return outputBuffer;
  }

  static $pb.GeneratedMessage _unwrapProtoMsg(String inputBuffer) {
    try {
      Uint8List inputBytes = ByteOperationsUtils.convertHexStringToBytes(inputBuffer);
      Uint8List msgContents = inputBytes.sublist(6, 6 + _getMsgSize(inputBuffer));
      MessageType? messageType = MessageType.valueOf(_getMsgType(inputBuffer));
      return MsgMapper.getMsgFromType(messageType!, msgContents);
    } catch (e) {
      throw ArgumentError('Could not interpret bytes: $inputBuffer');
    }
  }

  static String _wrapProtoMsg($pb.GeneratedMessage protoMsgResponse) {
    int msgType = MsgMapper.getTypeNumber(protoMsgResponse);
    Uint8List msgBuffer = protoMsgResponse.writeToBuffer();

    int msgSize = msgBuffer.length;
    Uint8List msgTypeBytes = ByteOperationsUtils.convertIntToBigEndianBytes(msgType, 2);
    Uint8List msgSizeBytes = ByteOperationsUtils.convertIntToBigEndianBytes(msgSize, 4);

    Uint8List mergedDecBytes = ByteOperationsUtils.mergeUint8Lists(<Uint8List>[msgTypeBytes, msgSizeBytes, msgBuffer]);
    String mergedHexBytes = mergedDecBytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return mergedHexBytes;
  }



  static int _getMsgType(String inputBuffer) => ByteOperationsUtils.convertHexStringToInt(inputBuffer.substring(0, 4));

  static int _getMsgSize(String inputBuffer) => ByteOperationsUtils.convertHexStringToInt(inputBuffer.substring(4, 12));
}
