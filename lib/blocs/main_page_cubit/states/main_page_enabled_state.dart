import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/infra/trezor/trezor_event.dart';
import 'package:mirage/shared/models/pubkey_model.dart';

class MainPageEnabledState extends AMainPageState {
  final TrezorEvent activeEvent;
  final bool repeatedAttemptBool;

  const MainPageEnabledState({
    required this.activeEvent,
    this.repeatedAttemptBool = false,
    super.pubkeyModel,
  });

  @override
  AMainPageState copyWith({PubkeyModel? pubkeyModel}) {
    return MainPageEnabledState(
      activeEvent: activeEvent,
      pubkeyModel: pubkeyModel,
    );
  }

  String get title => activeEvent.trezorInteractiveRequest.title;

  List<String> get description => activeEvent.trezorInteractiveRequest.description;

  // TODO(Marcin): replace with "toSerializedCbor()" after CBOR implementation
  Map<String, String> get audioRequestData => activeEvent.trezorInteractiveRequest.getRequestData();

  // TODO(Marcin): temporary getter before CBOR implementation
  List<String> get inputStructure => activeEvent.trezorInteractiveRequest.expectedResponseStructure;

  @override
  List<Object?> get props => <Object?>[activeEvent, pubkeyModel];
}
