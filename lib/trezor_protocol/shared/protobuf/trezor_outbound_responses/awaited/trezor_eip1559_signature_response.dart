import 'dart:io';

import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorEIP1559SignatureResponse extends ATrezorAwaitedResponse {
  final int signatureV;
  final List<int> signatureR;
  final List<int> signatureS;

  TrezorEIP1559SignatureResponse({
    required this.signatureV,
    required this.signatureR,
    required this.signatureS,
  });

  factory TrezorEIP1559SignatureResponse.getDataFromUser() {
    stdout.write('Enter signatureV: ');
    String signatureVLine = stdin.readLineSync()!;

    stdout.write('Enter signatureR: ');
    String signatureRLine = stdin.readLineSync()!;

    stdout.write('Enter signatureS: ');
    String signatureSLine = stdin.readLineSync()!;

    return TrezorEIP1559SignatureResponse(
      signatureV: int.parse(signatureVLine),
      signatureR: BytesUtils.parseStringToList(signatureRLine),
      signatureS: BytesUtils.parseStringToList(signatureSLine),
    );
  }

  @override
  GeneratedMessage toProtobufMsg() {
    return EthereumTxRequest(
      signatureV: signatureV,
      signatureR: signatureR,
      signatureS: signatureS,
    );
  }

  @override
  List<Object?> get props => <Object>[signatureV, signatureR, signatureS];
}
