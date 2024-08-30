import 'package:mirage/blocs/main_page_cubit/a_main_page_state.dart';
import 'package:mirage/blocs/main_page_cubit/interactive_request_received_event.dart';

class MainPageEnabledState extends AMainPageState {
  final InteractiveRequestReceivedEvent activeEvent;

  MainPageEnabledState({
    required this.activeEvent,
  });

  String get title => activeEvent.trezorInteractiveRequest.title;

  List<String> get description => activeEvent.trezorInteractiveRequest.description;

  // TODO(Marcin): replace with "toSerializedCbor()" after CBOR implementation
  Map<String, String> get audioRequestData => activeEvent.trezorInteractiveRequest.getRequestData();

  // TODO(Marcin): temporary method before CBOR implementation
  List<String> get inputStructure => activeEvent.trezorInteractiveRequest.expectedResponseStructure;

  @override
  List<Object?> get props => <Object>[activeEvent];
}