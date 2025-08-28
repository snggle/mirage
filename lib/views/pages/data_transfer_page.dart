import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_supervisor_cubit/audio_supervisor_cubit.dart';
import 'package:mirage/blocs/audio_supervisor_cubit/audio_supervisor_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_recorded_state.dart';
import 'package:mirage/blocs/receive_section_cubit/receive_section_cubit.dart';
import 'package:mirage/blocs/receive_section_cubit/states/receive_section_recording_state.dart';
import 'package:mirage/blocs/send_section_cubit/send_section_cubit.dart';
import 'package:mirage/blocs/send_section_cubit/states/send_section_emitting_state.dart';
import 'package:mirage/views/pages/audio_result_widget.dart';
import 'package:mirage/views/pages/audio_recording_section.dart';
import 'package:mirage/views/pages/request_description_widget.dart';
import 'package:mirage/views/pages/send_section.dart';

class DataTransferPage extends StatefulWidget {
  final MainPageEnabledState mainPageState;
  final ValueChanged<Uint8List> onSubmitted;
  final VoidCallback onCompleted;
  final Future<bool> Function() isDeviceListEmpty;

  const DataTransferPage({
    required this.mainPageState,
    required this.onSubmitted,
    required this.onCompleted,
    required this.isDeviceListEmpty,
    super.key,
  });

  @override
  State<DataTransferPage> createState() => _DataTransferPageState();
}

class _DataTransferPageState extends State<DataTransferPage> {
  final AudioSupervisorCubit _audioSupervisorCubit = AudioSupervisorCubit();
  late final SendSectionCubit _sendSectionCubit;
  late final ReceiveSectionCubit _receiveSectionCubit;

  @override
  void initState() {
    _sendSectionCubit = SendSectionCubit(audioSupervisorCubit: _audioSupervisorCubit);
    _receiveSectionCubit = ReceiveSectionCubit(audioSupervisorCubit: _audioSupervisorCubit);
    super.initState();
  }

  @override
  void dispose() {
    _receiveSectionCubit.close();
    _sendSectionCubit.close();
    _audioSupervisorCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String>? description = widget.mainPageState.description;

    return BlocBuilder<AudioSupervisorCubit, AudioSupervisorState>(
        bloc: _audioSupervisorCubit,
        builder: (BuildContext context, AudioSupervisorState state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.mainPageState.repeatedAttemptBool) ...<Widget>[
                    const Text('Invalid message. Please try again.', style: TextStyle(color: Colors.red)),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                  Text(widget.mainPageState.title, style: const TextStyle(fontSize: 20)),
                  if (description.isNotEmpty) RequestDescriptionWidget(description: description),
                  const SizedBox(height: 10),
                  if (widget.mainPageState is MainPageRecordedState == false) ...<Widget>[
                    SendSection(
                      msgUint8List: widget.mainPageState.audioRequestData,
                      sendSectionCubit: _sendSectionCubit,
                      sectionBlockedBool: _receiveSectionCubit.state is ReceiveSectionRecordingState,
                    ),
                    const SizedBox(height: 20),
                    AudioRecordingSection(
                      onSubmitted: widget.onSubmitted,
                      isDeviceListEmpty: widget.isDeviceListEmpty,
                      receiveSectionCubit: _receiveSectionCubit,
                      sectionBlockedBool: _sendSectionCubit.state is SendSectionEmittingState,
                    ),
                    const SizedBox(height: 40),
                  ],
                  if (widget.mainPageState is MainPageRecordedState) ...<Widget>[
                    AudioResultWidget(
                      recordValidBool: (widget.mainPageState as MainPageRecordedState).recordValidBool,
                      onCompleted: widget.onCompleted,
                    ),
                  ],
                ],
              ),
            ),
          );
        });
  }
}
