import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/shared/utils/bytes_utils.dart';
import 'package:protobuf/protobuf.dart';

class TrezorEthMsgSignatureResponse extends ATrezorAwaitedResponse {
  final String address;
  final List<int> signature;

  TrezorEthMsgSignatureResponse({
    required this.address,
    required this.signature,
  });

  factory TrezorEthMsgSignatureResponse.getDataFromUser(List<String> userInput) {
    return TrezorEthMsgSignatureResponse(
      address: userInput[0],
      signature: BytesUtils.parseStringToList(userInput[1]),
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
