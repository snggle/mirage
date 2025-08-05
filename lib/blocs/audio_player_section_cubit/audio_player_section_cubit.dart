import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_player_section_cubit/a_audio_player_section_state.dart';
import 'package:mirage/blocs/audio_player_section_cubit/states/audio_player_section_emitting_state.dart';
import 'package:mirage/blocs/audio_player_section_cubit/states/audio_player_section_empty_state.dart';
import 'package:mirage/blocs/audio_supervisor_cubit/audio_supervisor_cubit.dart';
import 'package:mrumru/mrumru.dart';

class AudioPlayerSectionCubit extends Cubit<AAudioPlayerSectionState> {
  final AudioSupervisorCubit audioSupervisorCubit;
  late final AudioGenerator _audioGenerator;
  late AudioSettingsModel audioSettingsModel = AudioSettingsModel(frequencyGenerator: StandardFrequencyGenerator(subbandCount: 32));

  AudioPlayerSectionCubit({
    required this.audioSupervisorCubit,
  }) : super(AudioPlayerSectionEmptyState()) {
    _audioGenerator = AudioGenerator(onGenerationCompleted: () {
      emit(AudioPlayerSectionEmptyState());
      audioSupervisorCubit.refresh();
    });
  }

  Future<void> playSound(Uint8List msgUint8List) async {
    await _audioGenerator.startGenerating(AudioGeneratorParams(
      audioSettingsModel: audioSettingsModel,
      bytes: msgUint8List,
      audioSinkArgs: StreamAudioSinkArgs(),
    ));
    emit(AudioPlayerSectionEmittingState());
    audioSupervisorCubit.refresh();
  }

  void stopSound() {
    _audioGenerator.cancelGenerating();
  }
}
