import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/supplementary/a_trezor_supplementary_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';

abstract class ATrezorMultipartInteractiveRequest extends ATrezorInteractiveRequest {
  ATrezorOutboundResponse askForSupplementaryInfo();

  ATrezorMultipartInteractiveRequest fillData(ATrezorSupplementaryRequest trezorSupplementaryRequest);

  bool get requestReady;
}