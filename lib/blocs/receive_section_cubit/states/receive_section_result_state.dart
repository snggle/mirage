import 'package:mirage/blocs/receive_section_cubit/a_receive_section_state.dart';

class ReceiveSectionResultState extends AReceiveSectionState {
  final List<int> recordedData;
  final List<String> decodedMessageParts;
  final List<int> brokenMessageIndexes;

  ReceiveSectionResultState({
    required this.recordedData,
    required this.decodedMessageParts,
    required this.brokenMessageIndexes,
  });

  @override
  List<Object?> get props => <Object>[recordedData, decodedMessageParts, brokenMessageIndexes];
}
