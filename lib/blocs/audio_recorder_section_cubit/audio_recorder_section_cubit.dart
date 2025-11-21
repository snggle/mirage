import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/a_audio_recorder_section_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_empty_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_missing_data_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_recording_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_result_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_retrying_state.dart';
import 'package:mirage/blocs/visualizer_cubit/visualizer_cubit.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mrumru/mrumru.dart';

class AudioRecorderSectionCubit extends Cubit<AAudioRecorderSectionState> {
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
  final AudioSettingsModel _audioSettingsModel = AudioSettingsModel(frequencyGenerator: StandardFrequencyGenerator(subbandCount: 32));
  final VoidCallback onRecorded;

  late final AudioDecoder _audioDecoder;

  int? _allFramesCount;
  int _receivedFramesCount = 0;

  AudioRecorderSectionCubit({required this.onRecorded}) : super(AudioRecorderSectionEmptyState()) {
    _audioDecoder = AudioDecoder(
      onMetadataFrameReceived: _handleMetadataFrameReceived,
      onDataFrameReceived: _handleDataFrameReceived,
      onDecodingCompleted: _handleDecodingCompleted,
      onDecodingFailed: _handleDecodingFailed,
    );
  }

  @override
  Future<void> close() async {
    await stopRecording(retryingBool: false);
    await super.close();
  }

  Future<void> startRecording() async {
    try {
      globalLocator<VisualizerCubit>().switchToRecording();
      await _audioDecoder.startRecording(_audioSettingsModel);
      _allFramesCount = null;
      _receivedFramesCount = 0;
      progressNotifier.value = 0;
      emit(AudioRecorderSectionRecordingState());
    } catch (e) {
      AppLogger().log(message: '\nCannot start recording: $e');
    }
  }

  Future<void> stopRecording({required bool retryingBool}) async {
    await _audioDecoder.cancelRecording();
    if (retryingBool) {
      emit(AudioRecorderSectionRetryingState());
    } else {
      emit(AudioRecorderSectionEmptyState());
    }
  }

  void _handleMetadataFrameReceived(MetadataFrameModel metadataFrameModel) {
    globalLocator<VisualizerCubit>().switchToDecoding();
    _allFramesCount = metadataFrameModel.dataFramesCount + 1;
    _receivedFramesCount++;
    progressNotifier.value += 1 / (_allFramesCount!);
  }

  void _handleDataFrameReceived(DataFrameModel dataFrameModel) {
    _receivedFramesCount++;
    progressNotifier.value += 1 / (_allFramesCount!);
  }

  void _handleDecodingCompleted(FrameCollectionModel frameCollectionModel) {
    bool transferInitFailedBool = _receivedFramesCount == 0;
    if (transferInitFailedBool) {
      return;
    }

    bool missingFramesBool = _allFramesCount! != _receivedFramesCount;
    if (missingFramesBool) {
      return;
    }

    List<int> brokenFrameIndexList = frameCollectionModel.getBrokenDataFrameIndexes();
    Uint8List recordedDataBytes = frameCollectionModel.rawDataBytes;

    if (brokenFrameIndexList.isEmpty) {
      onRecorded.call();
      emit(AudioRecorderSectionResultState(recordedDataBytes: Uint8List.fromList(recordedDataBytes)));
    } else {
      globalLocator<VisualizerCubit>().switchToRecording();
      emit(AudioRecorderSectionMissingDataState(
        correctDataFramesCount: _allFramesCount! - 1 - frameCollectionModel.getBrokenDataFrameIndexes().length,
        allDataFramesCount: _allFramesCount! - 1,
      ));
    }
  }

  Future<void> _handleDecodingFailed() async {
    globalLocator<VisualizerCubit>().switchToRecording();
    await stopRecording(retryingBool: true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    await startRecording();
  }
}
