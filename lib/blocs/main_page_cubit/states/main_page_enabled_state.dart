import 'dart:typed_data';

import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_eip1559_signature_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_eth_msg_signature_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_public_key_request.dart';
import 'package:mirage/infra/trezor/ws/trezor_ws_event.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

class MainPageEnabledState extends AMainPageState {
  final TrezorWsEvent activeWsEvent;
  final bool repeatedAttemptBool;

  const MainPageEnabledState({
    required this.activeWsEvent,
    this.repeatedAttemptBool = false,
    super.pubkeyModel,
  });

  @override
  AMainPageState copyWith({PubkeyModel? pubkeyModel}) {
    return MainPageEnabledState(
      activeWsEvent: activeWsEvent,
      pubkeyModel: pubkeyModel,
    );
  }

  String get title => activeWsEvent.trezorInboundRequest.title;

  List<String> get description => activeWsEvent.trezorInboundRequest.description;

  Uint8List get audioRequestData {
    switch (activeWsEvent.trezorInboundRequest) {
      case TrezorPublicKeyRequest trezorPublicKeyRequest:
        return trezorPublicKeyRequest.toSerializedCbor();
      case TrezorEIP1559SignatureRequest trezorEIP1559SignatureRequest:
        return trezorEIP1559SignatureRequest.toSerializedCbor(pubkeyModel: pubkeyModel);
      case TrezorEthMsgSignatureRequest trezorEthMsgSignatureRequest:
        return trezorEthMsgSignatureRequest.toSerializedCbor(pubkeyModel: pubkeyModel);
      default:
        return activeWsEvent.trezorInboundRequest.toSerializedCbor();
    }
  }

  @override
  List<Object?> get props => <Object?>[activeWsEvent, pubkeyModel];
}
