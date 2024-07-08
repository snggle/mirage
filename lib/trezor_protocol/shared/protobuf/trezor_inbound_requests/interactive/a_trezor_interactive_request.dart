import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_inbound_requests/supplementary/a_trezor_supplementary_request.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/trezor_protocol/shared/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';

abstract class ATrezorInteractiveRequest extends ATrezorInboundRequest {
  ATrezorAwaitedResponse getResponseFromUser();

  ATrezorOutboundResponse askForSupplementaryInfo();

  ATrezorInteractiveRequest fillWithAnotherRequest(ATrezorSupplementaryRequest trezorSupplementaryRequest);

  bool get requestReadyBool;

  @override
  List<Object?> get props => <Object>[];
}
