import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_active_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_idle_state.dart';
import 'package:mirage/blocs/pubkey_cubit/pubkey_cubit.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/a_trezor_inbound_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_eip1559_signature_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_eth_msg_signature_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_public_key_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/trezor_public_key_response.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_ws_communication_notifier.dart';
import 'package:mirage/infra/trezor/ws/trezor_ws_event.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

class MainPageCubit extends Cubit<AMainPageState> {
  final TrezorWsCommunicationNotifier _trezorCommunicationNotifier = globalLocator<TrezorWsCommunicationNotifier>();
  final PubkeyCubit _pubkeyCubit = globalLocator<PubkeyCubit>();

  MainPageCubit() : super(MainPageIdleState()) {
    _trezorCommunicationNotifier.addListener(_handleTrezorEventChanged);
  }

  Future<void> processRecordedMsg(Uint8List recordedMsgUint8List) async {
    TrezorWsEvent activeWsEvent = (state as MainPageActiveState).activeWsEvent;
    if (activeWsEvent.trezorInboundRequest is TrezorPublicKeyRequest) {
      await _pubkeyCubit.uploadPubkey(recordedMsgUint8List);
    }

    PubkeyModel? pubkeyModel = _pubkeyCubit.state.pubkeyModel;
    ATrezorOutboundResponse? trezorOutboundResponse;

    try {
      switch (activeWsEvent.trezorInboundRequest) {
        case TrezorPublicKeyRequest trezorPublicKeyRequest:
          trezorOutboundResponse = await trezorPublicKeyRequest.getResponseFromCborPayload(recordedMsgUint8List);
        case TrezorEIP1559SignatureRequest trezorEIP1559SignatureRequest:
          trezorOutboundResponse = await trezorEIP1559SignatureRequest.getResponseFromCborPayload(recordedMsgUint8List);
        case TrezorEthMsgSignatureRequest trezorEthMsgSignatureRequest:
          trezorOutboundResponse = await trezorEthMsgSignatureRequest.getResponseFromCborPayload(recordedMsgUint8List, pubkeyModel: pubkeyModel);
      }
    } catch (e) {
      trezorOutboundResponse = null;
    }

    if (trezorOutboundResponse != null) {
      activeWsEvent.resolve(trezorOutboundResponse);
    } else {
      await _fetchResponseFromSnggle(activeWsEvent, pubkeyModel, repeatedAttemptBool: true);
    }
  }

  Future<void> cancel() async {
    switch (state) {
      case MainPageActiveState mainPageActiveState:
        mainPageActiveState.activeWsEvent.reject('Operation canceled');
      default:
        emit(MainPageIdleState());
    }
  }

  void updatePubkey({required PubkeyModel? pubkeyModel}) {
    if (state is MainPageActiveState) {
      emit((state as MainPageActiveState).copyWith(pubkeyModel: pubkeyModel));
    }
  }

  Future<void> _handleTrezorEventChanged() async {
    TrezorWsEvent? activeEvent = _trezorCommunicationNotifier.activeEvent;

    if (activeEvent == null) {
      emit(MainPageIdleState());
    } else {
      await _handleInteractiveRequest(activeEvent);
    }
  }

  Future<void> _handleInteractiveRequest(TrezorWsEvent activeWsEvent) async {
    ATrezorInboundRequest request = activeWsEvent.trezorInboundRequest;
    PubkeyModel? pubkeyModel = _pubkeyCubit.state.pubkeyModel;

    bool quickResponseBool = request is TrezorPublicKeyRequest && pubkeyModel != null;

    if (quickResponseBool) {
      TrezorPublicKeyResponse savedPubkeyResponse = request.fromSecp256k1PublicKey(pubkeyModel.secp256k1publicKey);
      activeWsEvent.resolve(savedPubkeyResponse);
    } else {
      await _fetchResponseFromSnggle(activeWsEvent, pubkeyModel);
    }
  }

  Future<void> _fetchResponseFromSnggle(TrezorWsEvent activeWsEvent, PubkeyModel? pubkeyModel, {bool repeatedAttemptBool = false}) async {
    emit(
      MainPageActiveState(
        activeWsEvent: activeWsEvent,
        pubkeyModel: pubkeyModel,
        repeatedAttemptBool: repeatedAttemptBool,
      ),
    );
  }
}
