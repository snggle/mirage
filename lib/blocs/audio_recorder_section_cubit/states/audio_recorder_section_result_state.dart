import 'package:mirage/blocs/audio_recorder_section_cubit/a_audio_recorder_section_state.dart';

class AudioRecorderSectionResultState extends AAudioRecorderSectionState {
  final List<int> recordedData;

  AudioRecorderSectionResultState({
    required this.recordedData,
  });

  @override
  List<Object?> get props => <Object>[recordedData];
}
