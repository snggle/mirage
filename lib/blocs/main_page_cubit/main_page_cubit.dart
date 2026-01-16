import 'dart:typed_data';

import 'package:codec_utils/codec_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_recorded_state.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/services/pubkey_service.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_eip1559_signature_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_eth_msg_signature_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_public_key_request.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/a_trezor_outbound_response.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/trezor_error_response.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_outbound_responses/trezor_public_key_response.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_ws_communication_notifier.dart';
import 'package:mirage/infra/trezor/ws/trezor_ws_event.dart';
import 'package:mirage/shared/models/pubkey_model.dart';
import 'package:mirage/shared/utils/app_logger.dart';

class MainPageCubit extends Cubit<AMainPageState> {
  final TrezorWsCommunicationNotifier _trezorCommunicationNotifier = globalLocator<TrezorWsCommunicationNotifier>();
  final PubkeyService _pubkeyService = globalLocator<PubkeyService>();

  MainPageCubit() : super(const MainPageDisabledState()) {
    _trezorCommunicationNotifier.addListener(_handleTrezorEventChanged);
  }

  @override
  Future<void> close() {
    _trezorCommunicationNotifier.dispose();
    return super.close();
  }

  Future<void> processRecordedMsg(String userData) async {
    Uint8List recordedMsgUint8List = HexCodec.decode(userData);

    TrezorWsEvent activeEvent = (state as MainPageEnabledState).activeEvent;
    ATrezorOutboundResponse? trezorOutboundResponse;

    try {
      switch (activeEvent.trezorInboundRequest) {
        case TrezorPublicKeyRequest trezorPublicKeyRequest:
          trezorOutboundResponse = await trezorPublicKeyRequest.getResponseFromCborPayload(recordedMsgUint8List);
          await _pubkeyService.saveXPub((trezorOutboundResponse as TrezorPublicKeyResponse).xpub);
          await loadPubkey();
        case TrezorEIP1559SignatureRequest trezorEIP1559SignatureRequest:
          trezorOutboundResponse = await trezorEIP1559SignatureRequest.getResponseFromCborPayload(recordedMsgUint8List);
        case TrezorEthMsgSignatureRequest trezorEthMsgSignatureRequest:
          trezorOutboundResponse =
              await trezorEthMsgSignatureRequest.getResponseFromCborPayload(recordedMsgUint8List, pubkeyModel: state.pubkeyModel);
      }
    } catch (e) {
      trezorOutboundResponse = TrezorErrorResponse(code: 'TREZOR_EXCEPTION', message: e.toString());
    }

    emit(MainPageRecordedState(
      trezorResponse: trezorOutboundResponse,
      activeEvent: (state as MainPageEnabledState).activeEvent,
      pubkeyModel: state.pubkeyModel,
    ));
  }

  Future<void> completeInteractiveRequest() async {
    MainPageRecordedState recordedState = state as MainPageRecordedState;
    TrezorWsEvent activeEvent = recordedState.activeEvent;

    if (recordedState.recordValidBool) {
      activeEvent.resolve(recordedState.trezorResponse!);
    } else {
      await _fetchResponseFromSnggle(activeEvent, repeatedAttemptBool: true);
    }
  }

  Future<void> loadPubkey() async {
    try {
      PubkeyModel pubkeyModel = await _pubkeyService.getPublicKey();
      emit(state.copyWith(pubkeyModel: pubkeyModel));
    } catch (e) {
      AppLogger().log(message: 'No active public key. Connect the wallet again.');
      return;
    }
  }

  Future<void> cancel() async {
    switch (state) {
      case MainPageEnabledState mainPageEnabledState:
        mainPageEnabledState.activeEvent.reject('Operation canceled');
      default:
        emit(MainPageDisabledState(pubkeyModel: state.pubkeyModel));
    }
  }

  Future<void> _handleTrezorEventChanged() async {
    TrezorWsEvent? activeEvent = _trezorCommunicationNotifier.activeEvent;

    if (activeEvent == null) {
      emit(MainPageDisabledState(pubkeyModel: state.pubkeyModel));
    } else {
      await _resolveInteractiveRequest(activeEvent);
    }
  }

  Future<void> _resolveInteractiveRequest(TrezorWsEvent activeEvent) async {
    await _fetchResponseFromSnggle(activeEvent);
  }

  Future<void> _fetchResponseFromSnggle(TrezorWsEvent activeEvent, {bool repeatedAttemptBool = false}) async {
    emit(
      MainPageEnabledState(activeEvent: activeEvent, pubkeyModel: state.pubkeyModel, repeatedAttemptBool: repeatedAttemptBool),
    );
  }
}
