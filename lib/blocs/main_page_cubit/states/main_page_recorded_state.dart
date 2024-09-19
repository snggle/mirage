import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';

class MainPageRecordedState extends MainPageEnabledState {
  final List<String> recordedData;

  const MainPageRecordedState({
    required this.recordedData,
    required super.activeEvent,
    required super.pubkeyModel,
  });

  @override
  List<Object?> get props => <Object?>[recordedData, activeEvent, pubkeyModel];
}
