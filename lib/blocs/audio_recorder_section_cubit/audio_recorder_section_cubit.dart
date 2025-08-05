import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/a_audio_recorder_section_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_failed_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_missing_data_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_recording_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_result_state.dart';
import 'package:mirage/blocs/audio_supervisor_cubit/audio_supervisor_cubit.dart';
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mrumru/mrumru.dart';

class AudioRecorderSectionCubit extends Cubit<AAudioRecorderSectionState> {
  final AudioSupervisorCubit? audioSupervisorCubit;
  late final AudioDecoder _audioDecoder;
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
  AudioSettingsModel audioSettingsModel = AudioSettingsModel(
    frequencyGenerator: StandardFrequencyGenerator(subbandCount: 32),
  );

  int? _allFramesCount;

  AudioRecorderSectionCubit({
    this.audioSupervisorCubit,
  }) : super(AudioRecorderSectionEmptyState()) {
    _audioDecoder = AudioDecoder(
      onMetadataFrameReceived: _handleMetadataFrameReceived,
      onDataFrameReceived: _handleDataFrameReceived,
      onDecodingCompleted: _handleDecodingCompleted,
      onDecodingFailed: _handleDecodingFailed,
    );
  }

  Future<void> startRecording() async {
    try {
      await _audioDecoder.startRecording(audioSettingsModel);
      _allFramesCount = null;
      emit(AudioRecorderSectionRecordingState());
      audioSupervisorCubit?.refresh();
      progressNotifier.value = 0;
    } catch (e) {
      AppLogger().log(message: 'Cannot start recording: $e');
      emit(AudioRecorderSectionEmptyState());
      audioSupervisorCubit?.refresh();
    }
  }

  Future<void> stopRecording() async {
    await _audioDecoder.cancelRecording();
    reset();
    audioSupervisorCubit?.refresh();
  }

  void reset() {
    _allFramesCount = null;
    progressNotifier.value = 0;
    emit(AudioRecorderSectionEmptyState());
  }

  void _handleMetadataFrameReceived(MetadataFrameModel metadataFrameModel) {
    _allFramesCount = metadataFrameModel.dataFramesCount + 1;
    progressNotifier.value += 1 / (_allFramesCount!);
  }

  void _handleDataFrameReceived(DataFrameModel dataFrameModel) {
    progressNotifier.value += 1 / (_allFramesCount!);
  }

  void _handleDecodingCompleted(FrameCollectionModel frameCollectionModel) {
    List<int> brokenFrameIndexList = frameCollectionModel.getBrokenDataFrameIndexes();
    Uint8List recordedDataBytes = frameCollectionModel.rawDataBytes;
    if (brokenFrameIndexList.isEmpty) {
      emit(AudioRecorderSectionResultState(recordedData: recordedDataBytes));
      audioSupervisorCubit?.refresh();
    } else {
      emit(AudioRecorderSectionFailedState(
        correctDataFramesCount: _allFramesCount! - 1 - frameCollectionModel.getBrokenDataFrameIndexes().length,
        allDataFramesCount: _allFramesCount! - 1,
      ));
    }
  }

  void _handleDecodingFailed() {
    emit(AudioRecorderSectionFailedState(
      correctDataFramesCount: 0,
      allDataFramesCount: 0,
    ));
    audioSupervisorCubit?.refresh();
  }
}
