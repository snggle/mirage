import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-common.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-management.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/protobuf_msg_mapper.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

void main() {
  Uint8List actualMsgEmptyContents = Uint8List.fromList(<int>[]);

  group('Tests of ProtobufMsgMapper.getMsgFromType() (for incoming messages)', () {
    test('Should [return Initialize] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_Initialize;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getMsgFromType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = Initialize();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return GetPublicKey] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_GetPublicKey;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getMsgFromType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = GetPublicKey();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return ButtonAck] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_ButtonAck;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getMsgFromType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = ButtonAck();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return GetAddress] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_GetAddress;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getMsgFromType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = GetAddress();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return PassphraseAck] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_PassphraseAck;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getMsgFromType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = PassphraseAck();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return GetFeatures] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_GetFeatures;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getMsgFromType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = GetFeatures();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return EthereumSignTxEIP1559] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_EthereumSignTxEIP1559;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getMsgFromType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = EthereumSignTxEIP1559();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });
  });

  group('Tests of ProtobufMsgMapper.getMsgTypeNumber() (for outgoing messages)', () {
    test('Should [return 12] if the message is PublicKey', () {
      // Arrange
      PublicKey actualMessage = PublicKey();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 12;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

    test('Should [return 17] if the message is Features', () {
      // Arrange
      Features actualMessage = Features();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 17;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

    test('Should [return 26] if the message is ButtonRequest', () {
      // Arrange
      ButtonRequest actualMessage = ButtonRequest();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 26;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

    test('Should [return 26] if the message is Address', () {
      // Arrange
      Address actualMessage = Address();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 30;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

    test('Should [return 26] if the message is PassphraseRequest', () {
      // Arrange
      PassphraseRequest actualMessage = PassphraseRequest();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 41;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

    test('Should [return 26] if the message is EthereumTxRequest', () {
      // Arrange
      EthereumTxRequest actualMessage = EthereumTxRequest();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 59;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });
  });
}
