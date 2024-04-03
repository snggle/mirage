
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/cubit/a_audio_transmission_state.dart';
import 'package:mirage/cubit/states/audio_transmission_empty_state.dart';
import 'package:mirage/cubit/states/audio_transmission_recording_state.dart';
import 'package:mirage/cubit/states/audio_transmission_result_state.dart';
import 'package:mrumru/mrumru.dart';

class AudioTransmissionCubit extends Cubit<AAudioTransmissionState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final FrameSettingsModel frameSettingsModel = FrameSettingsModel.withDefaults();
  final TextEditingController messageTextController = TextEditingController();

  late AudioRecorderController audioRecorderController;
  late AudioSettingsModel audioSettingsModel;

  AudioTransmissionCubit() : super(AudioTransmissionEmptyState()) {
    audioSettingsModel = AudioSettingsModel.withDefaults();
  }

  void playSound() {
    AudioGenerator audioGenerator = AudioGenerator(audioSettingsModel: audioSettingsModel, frameSettingsModel: frameSettingsModel);
    List<int> audioBytes = audioGenerator.generateWavFileBytes(messageTextController.text);
    Source source = BytesSource(Uint8List.fromList(audioBytes));
    audioPlayer.play(source);
  }

  void stopSound() {
    audioPlayer.stop();
  }

  void startRecording() {
    try {
      audioRecorderController = AudioRecorderController(
        audioSettingsModel: audioSettingsModel,
        frameSettingsModel: frameSettingsModel,
        onRecordingCompleted: _handleRecordingCompleted,
        onFrameReceived: _handleFrameReceived,
      );
      emit(AudioTransmissionRecordingState(decodedMessage: ''));
      audioRecorderController.startRecording();
    } catch (e) {
      AppLogger().log(message: 'Cannot start recording: $e');
      emit(AudioTransmissionEmptyState());
    }
  }

  void stopRecording() {
    audioRecorderController.stopRecording();
  }

  void _handleRecordingCompleted() {
    emit(AudioTransmissionResultState(decodedMessage: (state as AudioTransmissionRecordingState).decodedMessage));
  }

  void _handleFrameReceived(FrameModel frameModel) {
    String decodedMessage = frameModel.rawData;
    if (state is AudioTransmissionResultState) {
      decodedMessage = '${(state as AudioTransmissionResultState).decodedMessage}$decodedMessage';
    }
    emit(AudioTransmissionRecordingState(decodedMessage: decodedMessage));
  }

}
