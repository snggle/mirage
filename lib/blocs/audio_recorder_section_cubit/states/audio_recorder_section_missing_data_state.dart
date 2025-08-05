import 'package:mirage/blocs/audio_recorder_section_cubit/a_audio_recorder_section_state.dart';

class AudioRecorderSectionFailedState extends AAudioRecorderSectionState {
  final int correctDataFramesCount;
  final int allDataFramesCount;

  AudioRecorderSectionFailedState({
    required this.correctDataFramesCount,
    required this.allDataFramesCount,
  });

  @override
  List<Object?> get props => <Object>[correctDataFramesCount, allDataFramesCount];
}
