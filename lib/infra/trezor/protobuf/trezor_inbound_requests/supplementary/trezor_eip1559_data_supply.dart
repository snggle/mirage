import 'dart:typed_data';

import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/supplementary/a_trezor_supplementary_request.dart';

class TrezorEIP1559DataSupply extends ATrezorSupplementaryRequest {
  final Uint8List dataChunk;

  TrezorEIP1559DataSupply({
    required this.dataChunk,
  });

  factory TrezorEIP1559DataSupply.fromProtobufMsg(EthereumTxAck ethereumTxAck) {
    return TrezorEIP1559DataSupply(
      dataChunk: Uint8List.fromList(ethereumTxAck.dataChunk),
    );
  }

  @override
  List<Object?> get props => <Object>[dataChunk];
}
