import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorAskMoreDataResponse extends ATrezorOutboundResponse {
  final int requestedBytesLength;

  TrezorAskMoreDataResponse({
    required this.requestedBytesLength,
  });

  @override
  GeneratedMessage toProtobufMsg() {
    return EthereumTxRequest(dataLength: requestedBytesLength);
  }

  @override
  List<Object?> get props => <Object>[requestedBytesLength];
}
