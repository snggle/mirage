import 'package:equatable/equatable.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-ethereum.pb.dart';
import 'package:mirage/infra/trezor/protobuf/messages_compiled/messages-management.pb.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/automated/trezor_device_address_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/automated/trezor_init_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/automated/trezor_properties_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_eip1559_signature_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_eth_msg_signature_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_public_key_request.dart';
import 'package:protobuf/protobuf.dart' as protobuf;

abstract class ATrezorInboundRequest extends Equatable {
  static ATrezorInboundRequest fromProtobufMsg(protobuf.GeneratedMessage incomingMsg) {
    switch (incomingMsg) {
      case Initialize initialize:
        return TrezorInitRequest.fromProtobufMsg(initialize);
      case GetFeatures _:
        return TrezorPropertiesRequest();
      case GetAddress _:
        return TrezorDeviceAddressRequest();
      case GetPublicKey getPublicKey:
        return TrezorPublicKeyRequest.fromProtobufMsg(getPublicKey);
      case EthereumSignMessage ethereumSignMessage:
        return TrezorEthMsgSignatureRequest.fromProtobufMsg(ethereumSignMessage);
      case EthereumSignTxEIP1559 ethereumSignTxEIP1559:
        return TrezorEIP1559SignatureRequest.fromProtobufMsg(ethereumSignTxEIP1559);
      default:
        throw ArgumentError();
    }
  }
}
