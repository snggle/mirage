import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/protobuf/compiled/messages-bitcoin.pb.dart';
import 'package:mirage/protobuf/compiled/messages-common.pb.dart';
import 'package:mirage/protobuf/compiled/messages-ethereum-definitions.pb.dart';
import 'package:mirage/protobuf/compiled/messages-ethereum.pb.dart';
import 'package:mirage/protobuf/compiled/messages-management.pb.dart';
import 'package:mirage/protobuf/compiled/messages.pb.dart';
import 'package:mirage/protobuf/msg_serializer/msg_mapper.dart';
import 'package:mirage/shared/protobuf_responses/protobuf_responses.dart';
import 'package:protobuf/protobuf.dart' as $pb;

// ignore_for_file: avoid_print
class ProtobufController {
  bool passphraseGiven = false;
  int buttonRequests = 0;
  EthereumSignTxEIP1559? ethereumSignTxEIP1559;
  late $pb.GeneratedMessage lastResponse;

  final Stream<String> stdinBroadcast = stdin.transform(utf8.decoder).asBroadcastStream();

  Future<$pb.GeneratedMessage?> getResponse($pb.GeneratedMessage message) async {
    MessageType messageType = MsgMapper.getMsgType(message);
    switch (messageType.name.substring(12)) {
      case 'GetFeatures':
        Features msgFeatures = ProtobufResponses.featuresNoSession;
        lastResponse = msgFeatures;
        return msgFeatures;
      case 'Initialize':
        List<int>? sessionId = message.getField(1) as List<int>?;
        if (sessionId != null) {
          Features msgFeatures = ProtobufResponses.featuresAssignSession(sessionId);
          lastResponse = msgFeatures;
          return msgFeatures;
        }
        Features msgFeatures = ProtobufResponses.featuresRandomSession;
        lastResponse = msgFeatures;
        return msgFeatures;
      case 'GetAddress':
        Address msgAddress = ProtobufResponses.address;
        lastResponse = msgAddress;
        return msgAddress;
      case 'PassphraseAck':
        Address msgAddress = ProtobufResponses.address;
        lastResponse = msgAddress;
        return msgAddress;
      case 'GetPublicKey':
        if (lastResponse is PublicKey) {
          PublicKey msgPublicKey = await ProtobufResponses.publicKey(message as GetPublicKey);
          lastResponse = msgPublicKey;
          return msgPublicKey;
        } else {
          print('*** Exporting Public Key to MetaMask ***\nPress ENTER to continue');
          await _waitForEnter();
          PublicKey msgPublicKey = await ProtobufResponses.publicKey(message as GetPublicKey);
          lastResponse = msgPublicKey;
          return msgPublicKey;
        }
      case 'EthereumSignTxEIP1559':
        String tokenData = _getTokenInfo(message as EthereumSignTxEIP1559);
        print('*** Sending $tokenData to 0x${message.to} ***\nPress ENTER to continue');
        await _waitForEnter();
        ethereumSignTxEIP1559 = message;
        buttonRequests++;
        ButtonRequest msgButtonRequest = ProtobufResponses.buttonRequest1;
        lastResponse = msgButtonRequest;
        return msgButtonRequest;
      case 'ButtonAck':
        if (buttonRequests == 1) {
          buttonRequests++;
          ButtonRequest msgButtonRequest = ProtobufResponses.buttonRequest2;
          lastResponse = msgButtonRequest;
          return msgButtonRequest;
        } else if (buttonRequests == 2) {
          buttonRequests++;
          ButtonRequest msgButtonRequest = ProtobufResponses.buttonRequest3;
          lastResponse = msgButtonRequest;
          return msgButtonRequest;
        } else {
          EthereumTxRequest msgEthereumTxRequest = await ProtobufResponses.ethereumTxRequest(ethereumSignTxEIP1559!);
          lastResponse = msgEthereumTxRequest;
          return msgEthereumTxRequest;
        }
      default:
        return null;
    }
  }

  Future<void> _waitForEnter() async {
    final Completer<void> completer = Completer<void>();

    StreamSubscription<String>? subscription;
    subscription = stdinBroadcast.listen(
      (String line) {
        completer.complete();
        subscription!.cancel();
      },
    );

    return completer.future;
  }

  String _getTokenInfo(EthereumSignTxEIP1559 ethereumSignTxEIP1559) {
    String amount = _getAmount(ethereumSignTxEIP1559);
    String token = _getToken(ethereumSignTxEIP1559);

    return '$amount $token';
  }

  String _getAmount(EthereumSignTxEIP1559 ethereumSignTxEIP1559) {
    List<int> amountData = ethereumSignTxEIP1559.value;
    double value = int.parse('0x${HexEncoder.encode(amountData)}') / 1000000000000000000;
    return value.toString();
  }

  String _getToken(EthereumSignTxEIP1559 ethereumSignTxEIP1559) {
    List<int> encodedNetwork = ethereumSignTxEIP1559.definitions.encodedNetwork;
    List<int> encodedToken = ethereumSignTxEIP1559.definitions.encodedToken;

    if (encodedNetwork.isNotEmpty) {
      List<int> protobufPayload = encodedNetwork.sublist(12, 34);
      EthereumNetworkInfo ethereumNetworkInfo = EthereumNetworkInfo.fromBuffer(protobufPayload);
      return '${ethereumNetworkInfo.name} ${ethereumNetworkInfo.symbol}';
    } else {
      List<int> protobufPayload = encodedToken.sublist(12, 34);
      EthereumTokenInfo ethereumTokenInfo = EthereumTokenInfo.fromBuffer(protobufPayload);
      return '${ethereumTokenInfo.name} ${ethereumTokenInfo.symbol}';
    }
  }
}
