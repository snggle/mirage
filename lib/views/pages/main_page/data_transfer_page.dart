import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mirage/blocs/audio_player_section_cubit/audio_player_section_cubit.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/audio_recorder_section_cubit.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_active_state.dart';
import 'package:mirage/blocs/visualizer_cubit/visualizer_cubit.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/infra/trezor/api_methods/trezor_inbound_requests/trezor_public_key_request.dart';
import 'package:mirage/views/widgets/audio_player_section.dart';
import 'package:mirage/views/widgets/audio_recorder_section.dart';
import 'package:mirage/views/widgets/bullet_list_widget.dart';

class DataTransferPage extends StatefulWidget {
  final MainPageActiveState mainPageActiveState;
  final ValueChanged<Uint8List> onSubmitted;
  final Future<bool> Function() isDeviceListEmpty;
  final VoidCallback onCancel;

  const DataTransferPage({
    required this.mainPageActiveState,
    required this.onSubmitted,
    required this.isDeviceListEmpty,
    required this.onCancel,
    super.key,
  });

  @override
  State<DataTransferPage> createState() => _DataTransferPageState();
}

class _DataTransferPageState extends State<DataTransferPage> {
  late final AudioPlayerSectionCubit _audioPlayerSectionCubit;
  late final AudioRecorderSectionCubit _audioRecorderSectionCubit;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayerSectionCubit = AudioPlayerSectionCubit();
    _audioRecorderSectionCubit = AudioRecorderSectionCubit(
      onRecorded: () => globalLocator<VisualizerCubit>().switchToDataReady(),
    );
  }

  @override
  void dispose() {
    _audioPlayerSectionCubit.close();
    _audioRecorderSectionCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String>? description = widget.mainPageActiveState.description;

    if (widget.mainPageActiveState.activeWsEvent.trezorInboundRequest is TrezorPublicKeyRequest) {
      index = 1;
    }

    if (index == 0) {
      globalLocator<VisualizerCubit>().switchToReadyEmit();
    }

    List<Widget> dataTransferWidgets = <Widget>[
      AudioPlayerSection(
        msgUint8List: widget.mainPageActiveState.audioRequestData,
        audioPlayerSectionCubit: _audioPlayerSectionCubit,
        onProceed: _onProceed,
      ),
      AudioRecorderSection(
        onRecorded: widget.onSubmitted,
        isDeviceListEmpty: widget.isDeviceListEmpty,
        audioRecorderSectionCubit: _audioRecorderSectionCubit,
      ),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.mainPageActiveState.repeatedAttemptBool) ...<Widget>[
              const Text('Invalid message. Please try again.', style: TextStyle(color: Colors.red)),
              const SizedBox(
                height: 10,
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(widget.mainPageActiveState.title, style: const TextStyle(fontSize: 20)),
                OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
            if (description.isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              BulletListWidget(points: description),
            ],
            const SizedBox(height: 20),
            Center(child: dataTransferWidgets[index]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _onProceed() {
    setState(() {
      index = 1;
    });
  }
}
