import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/a_trezor_outbound_response.dart';

abstract class ATrezorAutomatedRequest extends ATrezorInboundRequest {
  ATrezorOutboundResponse getResponse({Secp256k1PublicKey? secp256k1publicKey});

  @override
  List<Object?> get props => <Object>[];
}
