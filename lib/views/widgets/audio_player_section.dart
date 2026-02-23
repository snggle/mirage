import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_player_section_cubit/a_audio_player_section_state.dart';
import 'package:mirage/blocs/audio_player_section_cubit/audio_player_section_cubit.dart';
import 'package:mirage/blocs/audio_player_section_cubit/states/audio_player_section_emitted_state.dart';
import 'package:mirage/blocs/audio_player_section_cubit/states/audio_player_section_emitting_state.dart';

class AudioPlayerSection extends StatefulWidget {
  final AudioPlayerSectionCubit audioPlayerSectionCubit;
  final Uint8List msgUint8List;
  final VoidCallback onProceed;

  const AudioPlayerSection({
    required this.audioPlayerSectionCubit,
    required this.msgUint8List,
    required this.onProceed,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AudioPlayerSectionState();
}

class _AudioPlayerSectionState extends State<AudioPlayerSection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocBuilder<AudioPlayerSectionCubit, AAudioPlayerSectionState>(
        bloc: widget.audioPlayerSectionCubit,
        builder: (BuildContext context, AAudioPlayerSectionState state) {
          bool emittingInProgressBool = state is AudioPlayerSectionEmittingState;
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: emittingInProgressBool
                        ? OutlinedButton(
                      onPressed: widget.audioPlayerSectionCubit.stopSound,
                      child: const Text('Stop emission', style: TextStyle(color: Colors.red)),
                    )
                        : OutlinedButton(
                      onPressed: () => widget.audioPlayerSectionCubit.playSound(widget.msgUint8List),
                      child: const Text('Emit audio', style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Opacity(
                      opacity: state is AudioPlayerSectionEmittedState ? 1.0 : 0.5,
                      child: ElevatedButton.icon(
                        onPressed: state is AudioPlayerSectionEmittedState ? widget.onProceed : null,
                        label: const Text('Continue to receive signature'),
                        icon: const Icon(Icons.navigate_next_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
