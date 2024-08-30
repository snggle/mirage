import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';

class MainPageRecordedState extends MainPageEnabledState {
  final List<String> recordedData;

  MainPageRecordedState({
    required this.recordedData,
    required super.activeEvent,
  });

  @override
  List<Object?> get props => <Object>[recordedData, activeEvent];
}