import 'package:mirage/blocs/receive_section_cubit/a_receive_section_state.dart';

class ReceiveSectionResultState extends AReceiveSectionState {
  final List<int> recordedData;
  final List<int> brokenMessageIndexes;

  ReceiveSectionResultState({
    required this.recordedData,
    required this.brokenMessageIndexes,
  });

  @override
  List<Object?> get props => <Object>[recordedData, brokenMessageIndexes];
}
