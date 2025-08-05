import 'package:mirage/blocs/receive_section_cubit/states/receive_section_result_state.dart';

class ReceiveSectionRecordingState extends ReceiveSectionResultState {
  ReceiveSectionRecordingState({
    required super.recordedData,
    required super.decodedMessageParts,
    required super.brokenMessageIndexes,
  });
}
