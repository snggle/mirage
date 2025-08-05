import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_supervisor_cubit/audio_supervisor_cubit.dart';
import 'package:mirage/blocs/send_section_cubit/a_send_tab_state.dart';
import 'package:mirage/blocs/send_section_cubit/states/send_section_emitting_state.dart';
import 'package:mirage/blocs/send_section_cubit/states/send_section_empty_state.dart';
import 'package:mrumru/mrumru.dart';

class SendSectionCubit extends Cubit<ASendSectionState> {
  final AudioSupervisorCubit audioSupervisorCubit;
  late final AudioGenerator _audioGenerator;
  late AudioSettingsModel audioSettingsModel = AudioSettingsModel(frequencyGenerator: StandardFrequencyGenerator(subbandCount: 32));

  SendSectionCubit({
    required this.audioSupervisorCubit,
  }) : super(SendSectionEmptyState()) {
    _audioGenerator = AudioGenerator(onGenerationCompleted: () {
      emit(SendSectionEmptyState());
      audioSupervisorCubit.refresh();
    });
  }

  Future<void> playSound(Uint8List msgUint8List) async {
    await _audioGenerator.startGenerating(AudioGeneratorParams(
      audioSettingsModel: audioSettingsModel,
      bytes: msgUint8List,
      audioSinkArgs: StreamAudioSinkArgs(),
    ));
    emit(SendSectionEmittingState());
    audioSupervisorCubit.refresh();
  }

  void stopSound() {
    _audioGenerator.cancelGenerating();
  }
}
