import 'dart:typed_data';

import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/a_trezor_supplementary_request.dart';

class TrezorTxDataSupply extends ATrezorSupplementaryRequest {
  final Uint8List dataChunk;

  TrezorTxDataSupply({
    required this.dataChunk,
  });

  factory TrezorTxDataSupply.fromProtobufMsg(EthereumTxAck ethereumTxAck) {
    return TrezorTxDataSupply(
      dataChunk: Uint8List.fromList(ethereumTxAck.dataChunk),
    );
  }

  @override
  List<Object?> get props => <Object>[dataChunk];
}
