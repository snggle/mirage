import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mirage/blocs/audio_recorder_section_cubit/audio_recorder_section_cubit.dart';
import 'package:mirage/views/widgets/audio_recorder_section.dart';
import 'package:mirage/views/widgets/bullet_list_widget.dart';

class ManualPubkeyUploadPage extends StatelessWidget {
  final Future<bool> Function() isDeviceListEmpty;
  final ValueChanged<Uint8List> onPubkeyUploaded;
  final VoidCallback onClose;
  final AudioRecorderSectionCubit audioRecorderSectionCubit = AudioRecorderSectionCubit();

  ManualPubkeyUploadPage({
    required this.isDeviceListEmpty,
    required this.onPubkeyUploaded,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Manual pubkey upload', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 16),
                    BulletListWidget(
                      points: <String>[
                        'open Snggle',
                        'click "Connect wallet" button with "Audio interface" selected',
                        'emit audio',
                        'remember to use the same wallet you have connected on MetaMask'
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),
          const SizedBox(height: 10),
          AudioRecorderSection(
            isDeviceListEmpty: isDeviceListEmpty,
            onSubmitted: onPubkeyUploaded,
            audioRecorderSectionCubit: audioRecorderSectionCubit,
            sectionBlockedBool: false,
          ),
        ],
      ),
    );
  }
}
