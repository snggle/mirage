import 'dart:typed_data';

import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-common.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-management.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages.pbenum.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

class ProtobufMsgMapper {
  /// This method facilitates deserialization of protobuf messages, it handles inbound messages only.
  static protobuf.GeneratedMessage getMsgFromType(MessageType messageType, Uint8List msgContents) {
    switch (messageType) {
      case MessageType.MessageType_Initialize:
        return Initialize.fromBuffer(msgContents);
      case MessageType.MessageType_GetPublicKey:
        return GetPublicKey.fromBuffer(msgContents);
      case MessageType.MessageType_ButtonAck:
        return ButtonAck.fromBuffer(msgContents);
      case MessageType.MessageType_GetAddress:
        return GetAddress.fromBuffer(msgContents);
      case MessageType.MessageType_PassphraseAck:
        return PassphraseAck.fromBuffer(msgContents);
      case MessageType.MessageType_GetFeatures:
        return GetFeatures.fromBuffer(msgContents);
      case MessageType.MessageType_EthereumSignTxEIP1559:
        return EthereumSignTxEIP1559.fromBuffer(msgContents);
      default:
        throw ArgumentError('Unknown message type: $messageType');
    }
  }

  /// This method facilitates serialization of protobuf messages, it handles outbound messages only.
  static int getMsgTypeNumber(protobuf.GeneratedMessage msg) {
    if (msg is PublicKey) {
      return 12; // hex: 000c
    } else if (msg is Features) {
      return 17; // hex: 0011
    } else if (msg is ButtonRequest) {
      return 26; // hex: 001a
    } else if (msg is Address) {
      return 30; // hex: 001e
    } else if (msg is PassphraseRequest) {
      return 41; // hex: 0029
    } else if (msg is EthereumTxRequest) {
      return 59; // hex: 003b
    } else {
      throw ArgumentError('Unknown message: $msg');
    }
  }
}
