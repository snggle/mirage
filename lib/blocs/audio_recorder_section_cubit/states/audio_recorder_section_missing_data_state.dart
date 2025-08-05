import 'package:mirage/blocs/audio_recorder_section_cubit/a_audio_recorder_section_state.dart';

class AudioRecorderSectionMissingDataState extends AAudioRecorderSectionState {
  final int correctDataFramesCount;
  final int allDataFramesCount;

  AudioRecorderSectionMissingDataState({
    required this.correctDataFramesCount,
    required this.allDataFramesCount,
  });

  @override
  List<Object?> get props => <Object>[correctDataFramesCount, allDataFramesCount];
}
