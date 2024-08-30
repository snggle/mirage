import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/interactive_request_received_event.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_recorded_state.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';
import 'package:mirage/infra/trezor/trezor_communication_notifier.dart';

class MainPageCubit extends Cubit<AMainPageState> {
  final TrezorCommunicationNotifier _trezorCommunicationNotifier = globalLocator<TrezorCommunicationNotifier>();

  MainPageCubit() : super(MainPageDisabledState()) {
    _trezorCommunicationNotifier.addListener(_handleTrezorInteractiveRequest);
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
    (state as MainPageEnabledState).activeEvent.reject('Operation canceled');
    emit(MainPageDisabledState());
  }

  void disableAudioTransmission() {
    MainPageRecordedState recordedState = state as MainPageRecordedState;
    InteractiveRequestReceivedEvent activeEvent = recordedState.activeEvent;

    ATrezorAwaitedResponse trezorAwaitedResponse = activeEvent.trezorInteractiveRequest.getResponseFromUserInput(recordedState.recordedData);
    activeEvent.resolve(trezorAwaitedResponse);
  }

  void _handleTrezorInteractiveRequest() {
    InteractiveRequestReceivedEvent? activeEvent = _trezorCommunicationNotifier.activeEvent;

    if (activeEvent == null) {
      emit(MainPageDisabledState());
    } else {
      emit(MainPageEnabledState(activeEvent: activeEvent));
    }
  }

  String? get activeWalletPublicKey {
    try {
      return globalLocator<TrezorCommunicationNotifier>().savedPubkeyModel.publicAddressHex;
    } catch (e) {
      return null;
    }
  }
}
