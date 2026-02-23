import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mirage/blocs/audio_player_section_cubit/audio_player_section_cubit.dart';
import 'package:mirage/blocs/audio_player_section_cubit/states/audio_player_section_emitting_state.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/audio_recorder_section_cubit.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/states/audio_recorder_section_recording_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/infra/trezor/protobuf/trezor_inbound_requests/interactive/trezor_public_key_request.dart';
import 'package:mirage/views/widgets/audio_player_section.dart';
import 'package:mirage/views/widgets/audio_recorder_section.dart';
import 'package:mirage/views/widgets/bullet_list_widget.dart';

class DataTransferPage extends StatefulWidget {
  final MainPageEnabledState mainPageState;
  final ValueChanged<Uint8List> onSubmitted;
  final Future<bool> Function() isDeviceListEmpty;

  const DataTransferPage({
    required this.mainPageState,
    required this.onSubmitted,
    required this.isDeviceListEmpty,
    super.key,
  });

  @override
  State<DataTransferPage> createState() => _DataTransferPageState();
}

class _DataTransferPageState extends State<DataTransferPage> {
  late final AudioPlayerSectionCubit _audioPlayerSectionCubit;
  late final AudioRecorderSectionCubit _audioRecorderSectionCubit;

  @override
  void dispose() {
    _audioRecorderSectionCubit.close();
    _audioPlayerSectionCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String>? description = widget.mainPageState.description;

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
            if (description.isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              BulletListWidget(points: description),
            ],
            if (widget.mainPageState.activeEvent.trezorInboundRequest is TrezorPublicKeyRequest == false) ...<Widget>[
              const SizedBox(height: 20),
              AudioPlayerSection(
                msgUint8List: widget.mainPageState.audioRequestData,
                audioPlayerSectionCubit: _audioPlayerSectionCubit,
                sectionBlockedBool: _audioRecorderSectionCubit.state is AudioRecorderSectionRecordingState,
              ),
            ],
            const SizedBox(height: 20),
            AudioRecorderSection(
              onSubmitted: widget.onSubmitted,
              isDeviceListEmpty: widget.isDeviceListEmpty,
              audioRecorderSectionCubit: _audioRecorderSectionCubit,
              sectionBlockedBool: _audioPlayerSectionCubit.state is AudioPlayerSectionEmittingState,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
