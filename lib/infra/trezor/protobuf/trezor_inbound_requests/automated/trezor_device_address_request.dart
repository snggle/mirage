import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/automated/a_trezor_automated_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/trezor_device_address_response.dart';

class TrezorDeviceAddressRequest extends ATrezorAutomatedRequest {
  @override
  ATrezorOutboundResponse getResponse({Secp256k1PublicKey? secp256k1publicKey}) {
    return TrezorDeviceAddressResponse.defaultResponse();
  }
}
