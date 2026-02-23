import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/a_audio_recorder_section_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/audio_recorder_section_cubit.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_empty_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_missing_data_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_recording_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_result_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_retrying_state.dart';
import 'package:mirage/views/widgets/custom_linear_progress_indicator.dart';

class AudioRecorderSection extends StatefulWidget {
  final AudioRecorderSectionCubit audioRecorderSectionCubit;
  final ValueChanged<Uint8List> onRecorded;
  final Future<bool> Function() isDeviceListEmpty;

  const AudioRecorderSection({
    required this.audioRecorderSectionCubit,
    required this.onRecorded,
    required this.isDeviceListEmpty,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AudioRecorderSectionState();
}

class _AudioRecorderSectionState extends State<AudioRecorderSection> {
  bool _micActiveBool = true;
  bool _lastDeviceEmpty = false;
  Timer? _devicePollTimer;

  Uint8List? _recordedBytes;

  @override
  void initState() {
    super.initState();
    _startDevicePolling();
    _tryStartRecording();
  }

  @override
  void dispose() {
    _devicePollTimer?.cancel();
    widget.audioRecorderSectionCubit.stopRecording(retryingBool: false);
    super.dispose();
  }

  void _startDevicePolling() {
    _devicePollTimer?.cancel();
    _devicePollTimer = Timer.periodic(const Duration(milliseconds: 2000), (_) async {
      final bool isEmpty = await widget.isDeviceListEmpty();

      if (isEmpty != _lastDeviceEmpty) {
        _lastDeviceEmpty = isEmpty;

        if (!mounted) {
          return;
        }

        if (isEmpty) {
          setState(() => _micActiveBool = false);
          await widget.audioRecorderSectionCubit.stopRecording(retryingBool: false);
        } else {
          setState(() => _micActiveBool = true);
          await widget.audioRecorderSectionCubit.startRecording();
        }
      }
    });
  }

  Future<void> _tryStartRecording() async {
    final bool deviceListEmptyBool = await widget.isDeviceListEmpty();
    if (!mounted) {
      return;
    }

    setState(() {
      _recordedBytes = null;
      _micActiveBool = !deviceListEmptyBool;
    });

    if (!deviceListEmptyBool) {
      await widget.audioRecorderSectionCubit.startRecording();
    }
  }

  void _finish() {
    final Uint8List? bytes = _recordedBytes;
    if (bytes == null) {
      return;
    }
    widget.onRecorded(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioRecorderSectionCubit, AAudioRecorderSectionState>(
      bloc: widget.audioRecorderSectionCubit,
      builder: (BuildContext context, AAudioRecorderSectionState state) {
        if (state is AudioRecorderSectionResultState && _recordedBytes == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            setState(() => _recordedBytes = state.recordedDataBytes);
          });
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_micActiveBool == false) ...<Widget>[
              const Icon(Icons.mic_off_outlined, size: 40),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Text('No microphone detected', textAlign: TextAlign.center),
              ),
            ],

            if (state is AudioRecorderSectionEmptyState && _micActiveBool) const CircularProgressIndicator(),

            if (state is AudioRecorderSectionRetryingState && _micActiveBool) ...<Widget>[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Connection failed, try again'),
            ],

            if (state is AudioRecorderSectionRecordingState && _micActiveBool) ...<Widget>[
              const SizedBox(height: 10),
              const Text('Mirage is recording audio data...'),
              const SizedBox(height: 20),
              SizedBox(
                child: CustomLinearProgressIndicator(
                  progressNotifier: widget.audioRecorderSectionCubit.progressNotifier,
                ),
              ),
            ],

            if (state is AudioRecorderSectionMissingDataState && _micActiveBool) ...<Widget>[
              Text(
                'Some data was lost during transfer.\n'
                    '(${state.correctDataFramesCount}/${state.allDataFramesCount}) frames are correct.\n'
                    'Try reducing environmental noise.',
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _tryStartRecording,
                child: const Text('Try again'),
              )
            ],

            if (state is AudioRecorderSectionResultState && _micActiveBool) ...<Widget>[
              const Icon(Icons.check_circle_outline, size: 40),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  'Recording completed successfully.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _recordedBytes == null ? null : _finish,
                child: const Text('Finish'),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}
