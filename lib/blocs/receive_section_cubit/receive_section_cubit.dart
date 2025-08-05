import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_supervisor_cubit/audio_supervisor_cubit.dart';
import 'package:mirage/blocs/receive_section_cubit/a_receive_section_state.dart';
import 'package:mirage/blocs/receive_section_cubit/states/receive_section_empty_state.dart';
import 'package:mirage/blocs/receive_section_cubit/states/receive_section_recording_state.dart';
import 'package:mirage/blocs/receive_section_cubit/states/receive_section_result_state.dart';
import 'package:mirage/shared/utils/app_logger.dart';
import 'package:mrumru/mrumru.dart';

class ReceiveSectionCubit extends Cubit<AReceiveSectionState> {
  final AudioSupervisorCubit audioSupervisorCubit;
  final ValueNotifier<String> consoleNotifier = ValueNotifier<String>('');
  late final AudioDecoder _audioDecoder;
  AudioSettingsModel audioSettingsModel = AudioSettingsModel(frequencyGenerator: StandardFrequencyGenerator(subbandCount: 32));
  List<int> recordedData = List<int>.empty(growable: true);

  ReceiveSectionCubit({
    required this.audioSupervisorCubit,
  }) : super(ReceiveSectionEmptyState()) {
    _audioDecoder = AudioDecoder(
      onMetadataFrameReceived: _handleMetadataFrameReceived,
      onDataFrameReceived: _handleDataFrameReceived,
      onDecodingCompleted: _handleDecodingCompleted,
      onDecodingFailed: _handleDecodingFailed,
    );
  }

  Future<void> startRecording() async {
    recordedData = List<int>.empty(growable: true);
    try {
      await _audioDecoder.startRecording(audioSettingsModel);
      emit(ReceiveSectionRecordingState(
        recordedData: const <int>[],
        decodedMessageParts: const <String>[],
        brokenMessageIndexes: const <int>[],
      ));
      audioSupervisorCubit.refresh();
      consoleNotifier.value = '';
    } catch (e) {
      AppLogger().log(message: 'Cannot start recording: $e');
      emit(ReceiveSectionEmptyState());
      audioSupervisorCubit.refresh();
    }
  }

  Future<void> stopRecording() async {
    await _audioDecoder.cancelRecording();
    emit(ReceiveSectionEmptyState());
    audioSupervisorCubit.refresh();
  }

  void _handleMetadataFrameReceived(MetadataFrameModel metadataFrameModel) {
    consoleNotifier.value += 'MetadataFrameModel: total frames: ${metadataFrameModel.dataFramesCount}\n';
  }

  void _handleDataFrameReceived(DataFrameModel dataFrameModel) {
    consoleNotifier.value += '\nDataFrameModel (${dataFrameModel.frameIndex}): ${dataFrameModel.data}\n';
    recordedData.addAll(dataFrameModel.data);
  }

  void _handleDecodingCompleted(FrameCollectionModel frameCollectionModel) {
    List<String> decodedParts = frameCollectionModel.getMessageParts();
    emit(ReceiveSectionResultState(
      recordedData: recordedData,
      decodedMessageParts: decodedParts,
      brokenMessageIndexes: frameCollectionModel.getBrokenDataFrameIndexes(),
    ));
    audioSupervisorCubit.refresh();
  }

  void _handleDecodingFailed() {
    emit(ReceiveSectionResultState(
      recordedData: const <int>[],
      decodedMessageParts: const <String>[
        'TRANSFER FAILED!',
        '\nPlease reduce the environment noise or use different transfer parameters.',
      ],
      brokenMessageIndexes: const <int>[],
    ));
    audioSupervisorCubit.refresh();
  }
}
