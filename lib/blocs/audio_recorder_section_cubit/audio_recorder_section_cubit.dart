import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/a_audio_recorder_section_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_failed_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_missing_data_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_recording_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_result_state.dart';
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mrumru/mrumru.dart';

class AudioRecorderSectionCubit extends Cubit<AAudioRecorderSectionState> {
  late final AudioDecoder _audioDecoder;
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
  AudioSettingsModel audioSettingsModel = AudioSettingsModel(
    frequencyGenerator: StandardFrequencyGenerator(subbandCount: 32),
  );
  final VoidCallback onRecorded;

  int? _allFramesCount;

  AudioRecorderSectionCubit({required this.onRecorded}) : super(AudioRecorderSectionEmptyState()) {
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
      progressNotifier.value = 0;
    } catch (e) {
      AppLogger().log(message: 'Cannot start recording: $e');
      emit(AudioRecorderSectionEmptyState());
    }
  }

  Future<void> stopRecording() async {
    await _audioDecoder.cancelRecording();
    reset();
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
      onRecorded.call();
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
  }
}
