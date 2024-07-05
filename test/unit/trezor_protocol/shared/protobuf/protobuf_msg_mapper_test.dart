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

  group('Tests of ProtobufMsgMapper.getRequestFromProtobufType() (for incoming messages)', () {
    test('Should [return Initialize] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_Initialize;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getRequestFromProtobufType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = Initialize();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return GetPublicKey] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_GetPublicKey;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getRequestFromProtobufType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = GetPublicKey();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return ButtonAck] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_ButtonAck;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getRequestFromProtobufType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = ButtonAck();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return GetAddress] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_GetAddress;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getRequestFromProtobufType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = GetAddress();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return GetFeatures] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_GetFeatures;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getRequestFromProtobufType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = GetFeatures();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });

    test('Should [return EthereumSignTxEIP1559] from given message type and contents', () {
      // Arrange
      MessageType actualMessageType = MessageType.MessageType_EthereumSignTxEIP1559;

      // Act
      protobuf.GeneratedMessage actualProtobufMsg = ProtobufMsgMapper.getRequestFromProtobufType(actualMessageType, actualMsgEmptyContents);

      // Assert
      protobuf.GeneratedMessage expectedProtobufMsg = EthereumSignTxEIP1559();

      expect(actualProtobufMsg, expectedProtobufMsg);
    });
  });

  group('Tests of ProtobufMsgMapper.getMsgTypeNumber() (for all messages)', () {
    test('Should [return 0] if the message is Initialize', () {
      // Arrange
      Initialize actualMessage = Initialize();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 0;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

    test('Should [return 11] if the message is GetPublicKey', () {
      // Arrange
      GetPublicKey actualMessage = GetPublicKey();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 11;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

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

    test('Should [return 27] if the message is ButtonAck', () {
      // Arrange
      ButtonAck actualMessage = ButtonAck();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 27;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

    test('Should [return 29] if the message is GetAddress', () {
      // Arrange
      GetAddress actualMessage = GetAddress();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 29;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

    test('Should [return 30] if the message is Address', () {
      // Arrange
      Address actualMessage = Address();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 30;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

    test('Should [return 55] if the message is GetFeatures', () {
      // Arrange
      GetFeatures actualMessage = GetFeatures();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 55;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

    test('Should [return 59] if the message is EthereumTxRequest', () {
      // Arrange
      EthereumTxRequest actualMessage = EthereumTxRequest();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 59;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });

    test('Should [return 452] if the message is EthereumSignTxEIP1559', () {
      // Arrange
      EthereumSignTxEIP1559 actualMessage = EthereumSignTxEIP1559();

      // Act
      int actualMsgTypeNumber = ProtobufMsgMapper.getMsgTypeNumber(actualMessage);

      // Assert
      int expectedMsgTypeNumber = 452;

      expect(actualMsgTypeNumber, expectedMsgTypeNumber);
    });
  });

  group('Tests of ProtobufMsgMapper.getMsgType() (for outgoing messages)', () {
    test('Should [MessageType.MessageType_Features] if the message is Initialize', () {
      // Arrange
      Initialize actualMessage = Initialize();

      // Act
      MessageType actualMsgType = ProtobufMsgMapper.getMsgType(actualMessage);

      // Assert
      MessageType expectedMsgType = MessageType.MessageType_Initialize;

      expect(actualMsgType, expectedMsgType);
    });

    test('Should [MessageType.MessageType_GetPublicKey] if the message is GetPublicKey', () {
      // Arrange
      GetPublicKey actualMessage = GetPublicKey();

      // Act
      MessageType actualMsgType = ProtobufMsgMapper.getMsgType(actualMessage);

      // Assert
      MessageType expectedMsgType = MessageType.MessageType_GetPublicKey;

      expect(actualMsgType, expectedMsgType);
    });

    test('Should [MessageType.MessageType_PublicKey] if the message is PublicKey', () {
      // Arrange
      PublicKey actualMessage = PublicKey();

      // Act
      MessageType actualMsgType = ProtobufMsgMapper.getMsgType(actualMessage);

      // Assert
      MessageType expectedMsgType = MessageType.MessageType_PublicKey;

      expect(actualMsgType, expectedMsgType);
    });

    test('Should [MessageType.MessageType_Features] if the message is Features', () {
      // Arrange
      Features actualMessage = Features();

      // Act
      MessageType actualMsgType = ProtobufMsgMapper.getMsgType(actualMessage);

      // Assert
      MessageType expectedMsgType = MessageType.MessageType_Features;

      expect(actualMsgType, expectedMsgType);
    });

    test('Should [MessageType.MessageType_ButtonRequest] if the message is ButtonRequest', () {
      // Arrange
      ButtonRequest actualMessage = ButtonRequest();

      // Act
      MessageType actualMsgType = ProtobufMsgMapper.getMsgType(actualMessage);

      // Assert
      MessageType expectedMsgType = MessageType.MessageType_ButtonRequest;

      expect(actualMsgType, expectedMsgType);
    });

    test('Should [MessageType.MessageType_ButtonAck] if the message is ButtonAck', () {
      // Arrange
      ButtonAck actualMessage = ButtonAck();

      // Act
      MessageType actualMsgType = ProtobufMsgMapper.getMsgType(actualMessage);

      // Assert
      MessageType expectedMsgType = MessageType.MessageType_ButtonAck;

      expect(actualMsgType, expectedMsgType);
    });

    test('Should [MessageType.MessageType_GetAddress] if the message is GetAddress', () {
      // Arrange
      GetAddress actualMessage = GetAddress();

      // Act
      MessageType actualMsgType = ProtobufMsgMapper.getMsgType(actualMessage);

      // Assert
      MessageType expectedMsgType = MessageType.MessageType_GetAddress;

      expect(actualMsgType, expectedMsgType);
    });

    test('Should [MessageType.MessageType_Address] if the message is Address', () {
      // Arrange
      Address actualMessage = Address();

      // Act
      MessageType actualMsgType = ProtobufMsgMapper.getMsgType(actualMessage);

      // Assert
      MessageType expectedMsgType = MessageType.MessageType_Address;

      expect(actualMsgType, expectedMsgType);
    });

    test('Should [MessageType.MessageType_GetFeatures] if the message is GetFeatures', () {
      // Arrange
      GetFeatures actualMessage = GetFeatures();

      // Act
      MessageType actualMsgType = ProtobufMsgMapper.getMsgType(actualMessage);

      // Assert
      MessageType expectedMsgType = MessageType.MessageType_GetFeatures;

      expect(actualMsgType, expectedMsgType);
    });

    test('Should [MessageType.MessageType_EthereumTxRequest] if the message is EthereumTxRequest', () {
      // Arrange
      EthereumTxRequest actualMessage = EthereumTxRequest();

      // Act
      MessageType actualMsgType = ProtobufMsgMapper.getMsgType(actualMessage);

      // Assert
      MessageType expectedMsgType = MessageType.MessageType_EthereumTxRequest;

      expect(actualMsgType, expectedMsgType);
    });

    test('Should [MessageType.MessageType_EthereumSignTxEIP1559] if the message is EthereumSignTxEIP1559', () {
      // Arrange
      EthereumSignTxEIP1559 actualMessage = EthereumSignTxEIP1559();

      // Act
      MessageType actualMsgType = ProtobufMsgMapper.getMsgType(actualMessage);

      // Assert
      MessageType expectedMsgType = MessageType.MessageType_EthereumSignTxEIP1559;

      expect(actualMsgType, expectedMsgType);
    });
  });
}
