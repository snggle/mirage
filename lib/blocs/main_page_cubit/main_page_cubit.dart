import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_recorded_state.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/services/pubkey_service.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/multipart/trezor_eip1559_signature_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_eth_msg_signature_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/trezor_communication_notifier.dart';
import 'package:mirage/infra/trezor/trezor_event.dart';
import 'package:mirage/shared/models/pubkey_model.dart';
import 'package:mirage/shared/utils/app_logger.dart';

class MainPageCubit extends Cubit<AMainPageState> {
  final TrezorCommunicationNotifier _trezorCommunicationNotifier = globalLocator<TrezorCommunicationNotifier>();
  final PubkeyService _pubkeyService = globalLocator<PubkeyService>();

  MainPageCubit() : super(const MainPageDisabledState()) {
    _trezorCommunicationNotifier.addListener(_handleTrezorEventChanged);
  }

  @override
  Future<void> close() {
    _trezorCommunicationNotifier.dispose();
    return super.close();
  }

  Future<void> processRecordedMsg(Uint8List recordedMsgUint8List) async {
    TrezorEvent activeEvent = (state as MainPageEnabledState).activeEvent;
    ATrezorAwaitedResponse? trezorAwaitedResponse;

    try {
      switch (activeEvent.trezorInteractiveRequest) {
        case TrezorEIP1559SignatureRequest trezorEIP1559SignatureRequest:
          trezorAwaitedResponse = await trezorEIP1559SignatureRequest.getResponseFromCborPayload(recordedMsgUint8List);
        case TrezorEthMsgSignatureRequest trezorEthMsgSignatureRequest:
          trezorAwaitedResponse = await trezorEthMsgSignatureRequest.getResponseFromCborPayload(recordedMsgUint8List, pubkeyModel: state.pubkeyModel);
      }
    } catch (e) {
      trezorAwaitedResponse = null;
    }

    emit(MainPageRecordedState(
      trezorResponse: trezorAwaitedResponse,
      activeEvent: (state as MainPageEnabledState).activeEvent,
      pubkeyModel: state.pubkeyModel,
    ));
  }

  Future<void> completeInteractiveRequest() async {
    MainPageRecordedState recordedState = state as MainPageRecordedState;
    TrezorEvent activeEvent = recordedState.activeEvent;

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
    TrezorEvent? activeEvent = _trezorCommunicationNotifier.activeEvent;

    if (activeEvent == null) {
      emit(MainPageDisabledState(pubkeyModel: state.pubkeyModel));
    } else {
      await _resolveInteractiveRequest(activeEvent);
    }
  }

  Future<void> _resolveInteractiveRequest(TrezorEvent activeEvent) async {
    if (state.pubkeyModel == null) {
      activeEvent.reject('No public key data. Connect the wallet again.');
    } else {
      await _fetchResponseFromSnggle(activeEvent);
    }
  }

  Future<void> _fetchResponseFromSnggle(TrezorEvent activeEvent, {bool repeatedAttemptBool = false}) async {
    emit(
      MainPageEnabledState(activeEvent: activeEvent, pubkeyModel: state.pubkeyModel, repeatedAttemptBool: repeatedAttemptBool),
    );
  }
}
