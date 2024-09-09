import 'package:cryptography_utils/cryptography_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/interactive_request_received_event.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_recorded_state.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/services/pubkey_service.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_derived_public_key_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_public_key_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';
import 'package:mirage/infra/trezor/public_key_model.dart';
import 'package:mirage/infra/trezor/trezor_communication_notifier.dart';

class MainPageCubit extends Cubit<AMainPageState> {
  final TrezorCommunicationNotifier _trezorCommunicationNotifier = globalLocator<TrezorCommunicationNotifier>();
  final PubkeyService _pubkeyService = globalLocator<PubkeyService>();

  MainPageCubit() : super(MainPageDisabledState()) {
    _trezorCommunicationNotifier.addListener(_handleTrezorInteractiveRequestReceived);
  }

  @override
  Future<void> close() {
    _trezorCommunicationNotifier.dispose();
    return super.close();
  }

  void receiveRecordedMsg(List<String> userData) {
    emit(MainPageRecordedState(
      recordedData: userData,
      activeEvent: (state as MainPageEnabledState).activeEvent,
    ));
  }

  void cancel() {
    switch (state) {
      case MainPageEnabledState mainPageEnabledState:
        mainPageEnabledState.activeEvent.reject('Operation canceled');
      default:
        emit(MainPageDisabledState());
    }
  }

  Future<void> completeInteractiveRequest() async {
    MainPageRecordedState recordedState = state as MainPageRecordedState;
    InteractiveRequestReceivedEvent activeEvent = recordedState.activeEvent;

    // This switch case won't be necessary if each requests has its own page
    switch (activeEvent.trezorInteractiveRequest) {
      case TrezorPublicKeyRequest trezorPublicKeyRequest:
        TrezorPublicKeyResponse trezorPublicKeyResponse = trezorPublicKeyRequest.getResponseFromUserInput(recordedState.recordedData);
        await _pubkeyService.saveXPub(trezorPublicKeyResponse.xpub);
        activeEvent.resolve(trezorPublicKeyResponse);
        break;
      default:
        ATrezorAwaitedResponse trezorAwaitedResponse = activeEvent.trezorInteractiveRequest.getResponseFromUserInput(recordedState.recordedData);
        activeEvent.resolve(trezorAwaitedResponse);
    }
  }

  Future<void> _handleTrezorInteractiveRequestReceived() async {
    InteractiveRequestReceivedEvent? activeEvent = _trezorCommunicationNotifier.activeEvent;

    if (activeEvent == null) {
      emit(MainPageDisabledState());
    } else {
      await _resolveInteractiveRequest(activeEvent);
    }
  }

  Future<void> _resolveInteractiveRequest(InteractiveRequestReceivedEvent activeEvent) async {
    switch (activeEvent.trezorInteractiveRequest) {
      case TrezorDerivedPublicKeyRequest trezorDerivedPublicKeyRequest:
        return _resolveDerivedPublicKeyRequest(activeEvent, trezorDerivedPublicKeyRequest);
      default:
        _fetchResponseFromSnggle(activeEvent);
    }
  }

  Future<void> _resolveDerivedPublicKeyRequest(InteractiveRequestReceivedEvent activeEvent, TrezorDerivedPublicKeyRequest trezorDerivedPublicKeyRequest) async {
    try {
      PubkeyModel derivedPubkeyModel = await _pubkeyService.getDerivedPublicKey(trezorDerivedPublicKeyRequest.derivationPath.last);
      TrezorPublicKeyResponse derivedPubkeyResponse = trezorDerivedPublicKeyRequest.getResponse(derivedPubkeyModel.secp256k1publicKey);
      activeEvent.resolve(derivedPubkeyResponse);
    } catch (e) {
      // If, for some reason, key is not saved in the database ask snggle for it
      _fetchResponseFromSnggle(activeEvent);
    }
  }

  void _fetchResponseFromSnggle(InteractiveRequestReceivedEvent activeEvent) {
    emit(MainPageEnabledState(activeEvent: activeEvent));
  }
}
