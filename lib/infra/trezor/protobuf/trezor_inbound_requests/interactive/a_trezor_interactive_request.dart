import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';

abstract class ATrezorInteractiveRequest extends ATrezorInboundRequest {
  ATrezorAwaitedResponse getResponseFromUserInput(List<String> userInput);

  List<String> get description;

  // TODO(Marcin): temporary method before CBOR implementation
  List<String> get expectedResponseStructure;

  // TODO(Marcin): replace with "toSerializedCbor()" after CBOR implementation
  Map<String, String> getRequestData();

  String get title;

  @override
  List<Object?> get props => <Object>[];
}
