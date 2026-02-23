import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_player_section_cubit/a_audio_player_section_state.dart';
import 'package:mirage/blocs/audio_player_section_cubit/audio_player_section_cubit.dart';
import 'package:mirage/blocs/audio_player_section_cubit/states/audio_player_section_emitting_state.dart';

class AudioPlayerSection extends StatefulWidget {
  final bool sectionBlockedBool;
  final AudioPlayerSectionCubit audioPlayerSectionCubit;
  final Uint8List msgUint8List;

  const AudioPlayerSection({
    required this.sectionBlockedBool,
    required this.audioPlayerSectionCubit,
    required this.msgUint8List,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AudioPlayerSectionState();
}

class _AudioPlayerSectionState extends State<AudioPlayerSection> {
  bool savingBool = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocBuilder<AudioPlayerSectionCubit, AAudioPlayerSectionState>(
        bloc: widget.audioPlayerSectionCubit,
        builder: (BuildContext context, AAudioPlayerSectionState state) {
          bool emittingInProgressBool = state is AudioPlayerSectionEmittingState;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Opacity(
                        opacity: emittingInProgressBool ? 0.5 : 1.0,
                        child: OutlinedButton(
                          onPressed: (emittingInProgressBool || widget.sectionBlockedBool)
                              ? null
                              : () => widget.audioPlayerSectionCubit.playSound(widget.msgUint8List),
                          child: const Text('Emit audio', style: TextStyle(color: Colors.blue)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Opacity(
                        opacity: emittingInProgressBool ? 1.0 : 0.5,
                        child: OutlinedButton(
                          onPressed: (emittingInProgressBool && widget.sectionBlockedBool == false) ? widget.audioPlayerSectionCubit.stopSound : null,
                          child: const Text('Stop emission', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
