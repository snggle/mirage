import 'dart:typed_data';

import 'package:mirage/blocs/audio_recorder_section_cubit/a_audio_recorder_section_state.dart';

class AudioRecorderSectionResultState extends AAudioRecorderSectionState {
  final Uint8List recordedDataBytes;

  AudioRecorderSectionResultState({required this.recordedDataBytes});

  @override
  List<Object?> get props => <Object>[recordedDataBytes];
}
