import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_player_section_cubit/a_audio_player_section_state.dart';
import 'package:mirage/blocs/audio_player_section_cubit/states/audio_player_section_emitted_state.dart';
import 'package:mirage/blocs/audio_player_section_cubit/states/audio_player_section_emitting_state.dart';
import 'package:mirage/blocs/audio_player_section_cubit/states/audio_player_section_empty_state.dart';
import 'package:mrumru/mrumru.dart';

class AudioPlayerSectionCubit extends Cubit<AAudioPlayerSectionState> {
  late final AudioGenerator _audioGenerator;
  late AudioSettingsModel audioSettingsModel = AudioSettingsModel(frequencyGenerator: StandardFrequencyGenerator(subbandCount: 32));
  bool _cancelledByUserBool = false;

  AudioPlayerSectionCubit() : super(AudioPlayerSectionEmptyState()) {
    _audioGenerator = AudioGenerator(onGenerationCompleted: _handleGenerationCompleted);
  }

  @override
  Future<void> close() async {
    stopSound();
    await super.close();
  }

  Future<void> playSound(Uint8List msgUint8List) async {
    _cancelledByUserBool = false;
    await _audioGenerator.startGenerating(AudioGeneratorParams(
      audioSettingsModel: audioSettingsModel,
      bytes: msgUint8List,
      audioSinkArgs: StreamAudioSinkArgs(),
    ));
    emit(AudioPlayerSectionEmittingState());
  }

  void stopSound() {
    _audioGenerator.cancelGenerating();
    _cancelledByUserBool = true;
  }

  void _handleGenerationCompleted() {
    if (isClosed) {
      return;
    }

    if (_cancelledByUserBool) {
      emit(AudioPlayerSectionEmptyState());
    } else {
      emit(AudioPlayerSectionEmittedState());
    }
  }
}
