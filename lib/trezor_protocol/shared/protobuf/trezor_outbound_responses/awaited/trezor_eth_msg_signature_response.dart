import 'dart:io';

import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorEthMsgSignatureResponse extends ATrezorAwaitedResponse {
  final String address;
  final List<int> signature;

  TrezorEthMsgSignatureResponse({
    required this.address,
    required this.signature,
  });

  factory TrezorEthMsgSignatureResponse.getDataFromUser() {
    stdout.write('Enter signature: ');
    String signatureLine = stdin.readLineSync()!;

    stdout.write('Enter address: ');
    String addressLine = stdin.readLineSync()!;

    return TrezorEthMsgSignatureResponse(
      address: addressLine,
      signature: BytesUtils.parseStringToList(signatureLine),
    );
  }

  @override
  GeneratedMessage toProtobufMsg() {
    return EthereumMessageSignature(
      address: address,
      signature: signature,
    );
  }

  @override
  List<Object?> get props => <Object>[address, signature];
}
