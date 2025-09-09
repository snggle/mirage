import 'dart:typed_data';

import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_eip1559_signature_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_eth_msg_signature_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_public_key_request.dart';
import 'package:mirage/infra/trezor/ws/trezor_ws_event.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

class MainPageActiveState extends AMainPageState {
  final TrezorWsEvent activeWsEvent;
  final bool repeatedAttemptBool;
  final PubkeyModel? pubkeyModel;

  MainPageActiveState({
    required this.activeWsEvent,
    required this.pubkeyModel,
    this.repeatedAttemptBool = false,
  });

  AMainPageState copyWith({PubkeyModel? pubkeyModel}) {
    return MainPageActiveState(
      activeWsEvent: activeWsEvent,
      pubkeyModel: pubkeyModel,
    );
  }

  bool isPubkeyRequiredAndMissing() {
    if (activeWsEvent.trezorInboundRequest is TrezorPublicKeyRequest) {
      return false;
    } else {
      return pubkeyModel == null;
    }
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
