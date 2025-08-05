import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/send_section_cubit/a_send_tab_state.dart';
import 'package:mirage/blocs/send_section_cubit/send_section_cubit.dart';
import 'package:mirage/blocs/send_section_cubit/states/send_section_emitting_state.dart';

class SendSection extends StatefulWidget {
  final bool sectionBlockedBool;
  final SendSectionCubit sendSectionCubit;
  final Uint8List msgUint8List;

  const SendSection({
    required this.sectionBlockedBool,
    required this.sendSectionCubit,
    required this.msgUint8List,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _SendSectionState();
}

class _SendSectionState extends State<SendSection> {
  bool savingBool = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocBuilder<SendSectionCubit, ASendSectionState>(
        bloc: widget.sendSectionCubit,
        builder: (BuildContext context, ASendSectionState state) {
          bool emittingInProgressBool = state is SendSectionEmittingState;
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
                              : () {
                            widget.sendSectionCubit.playSound(widget.msgUint8List);
                                },
                          child: const Text('Emit message', style: TextStyle(color: Colors.blue)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Opacity(
                        opacity: emittingInProgressBool ? 1.0 : 0.5,
                        child: OutlinedButton(
                          onPressed: (emittingInProgressBool && widget.sectionBlockedBool == false) ? widget.sendSectionCubit.stopSound : null,
                          child: const Text('Stop emission', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
