import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/automated/a_trezor_automated_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/trezor_properties_response.dart';

class TrezorPropertiesRequest extends ATrezorAutomatedRequest {
  @override
  ATrezorOutboundResponse getResponse() {
    return TrezorPropertiesResponse.defaultResponse();
  }
}
