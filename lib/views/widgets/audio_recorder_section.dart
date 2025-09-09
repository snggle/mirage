import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/a_audio_recorder_section_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/audio_recorder_section_cubit.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_missing_data_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_recording_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_result_state.dart';
import 'package:mirage/views/widgets/custom_linear_progress_indicator.dart';

class AudioRecorderSection extends StatefulWidget {
  final bool sectionBlockedBool;
  final AudioRecorderSectionCubit audioRecorderSectionCubit;
  final ValueChanged<Uint8List> onSubmitted;
  final Future<bool> Function() isDeviceListEmpty;

  const AudioRecorderSection({
    required this.sectionBlockedBool,
    required this.audioRecorderSectionCubit,
    required this.onSubmitted,
    required this.isDeviceListEmpty,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AudioRecorderSectionState();
}

class _AudioRecorderSectionState extends State<AudioRecorderSection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocBuilder<AudioRecorderSectionCubit, AAudioRecorderSectionState>(
        bloc: widget.audioRecorderSectionCubit,
        builder: (BuildContext context, AAudioRecorderSectionState state) {
          bool recordingInProgressBool = state is AudioRecorderSectionRecordingState;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (recordingInProgressBool || widget.sectionBlockedBool) ? null : _startRecording,
                        child: const Text('Start recording'),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            (recordingInProgressBool && widget.sectionBlockedBool == false) ? widget.audioRecorderSectionCubit.stopRecording : null,
                        child: const Text('Stop recording'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (recordingInProgressBool) ...<Widget>[
                  const SizedBox(height: 20),
                  SizedBox(child: CustomLinearProgressIndicator(progressNotifier: widget.audioRecorderSectionCubit.progressNotifier)),
                ],
                if (state is AudioRecorderSectionFailedState)
                  Text(
                    state.allDataFramesCount == 0
                        ? 'Transfer failed.\nTry reducing environmental noise.'
                        : 'Some data was lost during transfer.\n(${state.correctDataFramesCount}/${state.allDataFramesCount}) frames are correct.\nTry reducing environmental noise.',
                    style: const TextStyle(),
                    textAlign: TextAlign.center,
                  ),
                if (state is AudioRecorderSectionResultState) ...<Widget>[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _submitRecordedData(Uint8List.fromList(state.recordedData)),
                    label: const Text('Submit'),
                    icon: const Icon(Icons.navigate_next_outlined),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _startRecording() async {
    bool deviceListEmptyBool = await widget.isDeviceListEmpty.call();
    if (deviceListEmptyBool) {
      _showDeviceInfoDialog(context);
    } else {
      await widget.audioRecorderSectionCubit.startRecording();
    }
  }

  void _showDeviceInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('No microphone detected'),
        content: const Text(
          'In order to use this feature, you need plug audio input device',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _submitRecordedData(Uint8List recordedData) {
    widget.onSubmitted(recordedData);
    widget.audioRecorderSectionCubit.reset();
  }
}
