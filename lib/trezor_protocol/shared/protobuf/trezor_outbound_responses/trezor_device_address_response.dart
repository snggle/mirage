import 'package:mirage/trezor_protocol/shared/protobuf/messages_compiled/messages-bitcoin.pb.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:protobuf/protobuf.dart';

class TrezorDeviceAddressResponse extends ATrezorOutboundResponse {
  final String address;

  TrezorDeviceAddressResponse({required this.address});

  factory TrezorDeviceAddressResponse.defaultResponse() {
    return TrezorDeviceAddressResponse(address: '');
  }

  @override
  GeneratedMessage toProtobufMsg() {
    return Address(address: address);
  }

  @override
  List<Object?> get props => <Object>[address];
}
