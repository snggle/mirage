import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_recorded_state.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/services/pubkey_service.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/a_trezor_interactive_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_public_key_request.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/trezor_public_key_response.dart';
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

  Future<void> loadPubkey() async {
    try {
      PubkeyModel pubkeyModel = await _pubkeyService.getPublicKey();
      emit(state.copyWith(pubkeyModel: pubkeyModel));
    } catch (e) {
      AppLogger().log(message: 'No active public key');
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

  Future<void> completeInteractiveRequest() async {
    MainPageRecordedState recordedState = state as MainPageRecordedState;
    TrezorEvent activeEvent = recordedState.activeEvent;

    try {
      switch (activeEvent.trezorInteractiveRequest) {
        case TrezorPublicKeyRequest trezorPublicKeyRequest:
          TrezorPublicKeyResponse trezorPublicKeyResponse = trezorPublicKeyRequest.getResponseFromUserInput(recordedState.recordedData);
          await _pubkeyService.saveXPub(trezorPublicKeyResponse.xpub);
          activeEvent.resolve(trezorPublicKeyResponse);
          await loadPubkey();
          break;
        default:
          ATrezorAwaitedResponse trezorAwaitedResponse = activeEvent.trezorInteractiveRequest.getResponseFromUserInput(recordedState.recordedData);
          activeEvent.resolve(trezorAwaitedResponse);
      }
    } catch (e) {
      await _fetchResponseFromSnggle(activeEvent, repeatedAttemptBool: true);
    }
  }

  Future<void> receiveRecordedMsg(List<String> userData) async {
    emit(MainPageRecordedState(
      recordedData: userData,
      activeEvent: (state as MainPageEnabledState).activeEvent,
      pubkeyModel: state.pubkeyModel,
    ));
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
    ATrezorInteractiveRequest request = activeEvent.trezorInteractiveRequest;
    if (request is TrezorPublicKeyRequest && request.derivationPath.length > 4) {
      return _derivePublicKey(activeEvent, request);
    } else {
      await _fetchResponseFromSnggle(activeEvent);
    }
  }

  Future<void> _derivePublicKey(TrezorEvent activeEvent, TrezorPublicKeyRequest trezorPublicKeyRequest) async {
    try {
      PubkeyModel derivedPubkeyModel = await _pubkeyService.getDerivedPublicKey(trezorPublicKeyRequest.derivationPath.last);
      TrezorPublicKeyResponse derivedPubkeyResponse = trezorPublicKeyRequest.getDerivedResponse(derivedPubkeyModel.secp256k1publicKey);
      activeEvent.resolve(derivedPubkeyResponse);
    } catch (e) {
      await _fetchResponseFromSnggle(activeEvent);
    }
  }

  Future<void> _fetchResponseFromSnggle(TrezorEvent activeEvent, {bool repeatedAttemptBool = false}) async {
    emit(
      MainPageEnabledState(activeEvent: activeEvent, pubkeyModel: state.pubkeyModel, repeatedAttemptBool: repeatedAttemptBool),
    );
  }
}
