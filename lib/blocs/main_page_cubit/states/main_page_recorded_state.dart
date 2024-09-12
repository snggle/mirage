import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_outbound_responses/awaited/a_trezor_awaited_response.dart';

class MainPageRecordedState extends MainPageEnabledState {
  final ATrezorAwaitedResponse? trezorResponse;

  const MainPageRecordedState({
    required this.trezorResponse,
    required super.activeEvent,
    required super.pubkeyModel,
  });

  bool get recordValidBool => trezorResponse != null;

  @override
  List<Object?> get props => <Object?>[trezorResponse, activeEvent, pubkeyModel];
}
