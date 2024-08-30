import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';
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

  factory TrezorEIP1559SignatureResponse.getDataFromUser(List<String> userInput) {
    return TrezorEIP1559SignatureResponse(
      signatureV: int.parse(userInput[0]),
      signatureR: BytesUtils.parseStringToList(userInput[1]),
      signatureS: BytesUtils.parseStringToList(userInput[2]),
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
