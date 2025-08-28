import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/receive_section_cubit/a_receive_section_state.dart';
import 'package:mirage/blocs/receive_section_cubit/receive_section_cubit.dart';
import 'package:mirage/blocs/receive_section_cubit/states/receive_section_recording_state.dart';
import 'package:mirage/blocs/receive_section_cubit/states/receive_section_result_state.dart';

class AudioRecordingSection extends StatefulWidget {
  final bool sectionBlockedBool;
  final ReceiveSectionCubit receiveSectionCubit;
  final ValueChanged<Uint8List> onSubmitted;
  final Future<bool> Function() isDeviceListEmpty;

  const AudioRecordingSection({
    required this.sectionBlockedBool,
    required this.receiveSectionCubit,
    required this.onSubmitted,
    required this.isDeviceListEmpty,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AudioRecordingSectionState();
}

class _AudioRecordingSectionState extends State<AudioRecordingSection> {
  final ScrollController _scrollController = ScrollController();
  bool _scrolledBottomBool = true;

  @override
  void initState() {
    super.initState();
    widget.receiveSectionCubit.consoleNotifier.addListener(_scrollToBottom);
    _scrollController.addListener(_handleUserScroll);
  }

  @override
  void dispose() {
    widget.receiveSectionCubit.consoleNotifier.removeListener(_scrollToBottom);
    _scrollController
      ..removeListener(_handleUserScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocBuilder<ReceiveSectionCubit, AReceiveSectionState>(
        bloc: widget.receiveSectionCubit,
        builder: (BuildContext context, AReceiveSectionState state) {
          bool recordingInProgressBool = state is ReceiveSectionRecordingState;
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
                        onPressed: (recordingInProgressBool && widget.sectionBlockedBool == false) ? widget.receiveSectionCubit.stopRecording : null,
                        child: const Text('Stop recording'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (state is ReceiveSectionResultState) ...<Widget>[
                  const SizedBox(height: 20),
                  if (state.brokenMessageIndexes.isEmpty && recordingInProgressBool == false)
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onSubmitted(Uint8List.fromList(state.recordedData));
                      },
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
      await widget.receiveSectionCubit.startRecording();
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _scrolledBottomBool) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleUserScroll() {
    if (_scrollController.hasClients) {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;

      _scrolledBottomBool = (maxScroll - currentScroll) < 20;
    }
  }
}
