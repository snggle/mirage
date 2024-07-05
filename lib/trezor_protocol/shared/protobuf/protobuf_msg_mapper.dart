import 'dart:typed_data';

import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-common.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-management.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages.pbenum.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

class ProtobufMsgMapper {
  /// This method facilitates deserialization of protobuf messages, it handles inbound messages only.
  static protobuf.GeneratedMessage getRequestFromProtobufType(MessageType messageType, Uint8List msgContents) {
    switch (messageType) {
      case MessageType.MessageType_Initialize:
        return Initialize.fromBuffer(msgContents);
      case MessageType.MessageType_GetPublicKey:
        return GetPublicKey.fromBuffer(msgContents);
      case MessageType.MessageType_ButtonAck:
        return ButtonAck.fromBuffer(msgContents);
      case MessageType.MessageType_GetAddress:
        return GetAddress.fromBuffer(msgContents);
      case MessageType.MessageType_GetFeatures:
        return GetFeatures.fromBuffer(msgContents);
      case MessageType.MessageType_EthereumTxAck:
        return EthereumTxAck.fromBuffer(msgContents);
      case MessageType.MessageType_EthereumSignMessage:
        return EthereumSignMessage.fromBuffer(msgContents);
      case MessageType.MessageType_EthereumSignTxEIP1559:
        return EthereumSignTxEIP1559.fromBuffer(msgContents);
      default:
        throw ArgumentError('Unknown message type: $messageType');
    }
  }

  static int getMsgTypeNumber(protobuf.GeneratedMessage msg) {
    MessageType messageType = getMsgType(msg);
    return messageType.value;
  }

  static MessageType getMsgType(protobuf.GeneratedMessage msg) {
    String msgName = msg.info_.messageName;

    return MessageType.values.firstWhere((MessageType messageType) {
      if (messageType.name.substring(12) == msgName) {
        return true;
      }
      return false;
    }, orElse: () {
      throw ArgumentError('Unknown message: $msg');
    });
  }
}
