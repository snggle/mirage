import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_transmission_cubit/a_audio_transmission_state.dart';
import 'package:mirage/blocs/audio_transmission_cubit/audio_transmission_cubit.dart';
import 'package:mirage/blocs/audio_transmission_cubit/states/audio_transmission_recording_state.dart';
import 'package:mirage/blocs/audio_transmission_cubit/states/audio_transmission_result_state.dart';

class TransmissionWidget extends StatefulWidget {
  final List<String> audioMsgOutbound;

  const TransmissionWidget({required this.audioMsgOutbound, Key? key}) : super(key: key);

  @override
  State<TransmissionWidget> createState() => _TransmissionWidgetState();
}

class _TransmissionWidgetState extends State<TransmissionWidget> {
  @override
  Widget build(BuildContext context) {
    final AudioTransmissionCubit audioTransmissionCubit = AudioTransmissionCubit(audioMsgOutbound: widget.audioMsgOutbound);
    return BlocBuilder<AudioTransmissionCubit, AAudioTransmissionState>(
      bloc: audioTransmissionCubit,
      builder: (BuildContext context, AAudioTransmissionState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              const Text('Emit audio'),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: audioTransmissionCubit.playSound,
                      child: const Text('Start emission'),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: audioTransmissionCubit.stopSound,
                      child: const Text('Stop emission'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Listen'),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state is AudioTransmissionRecordingState ? null : audioTransmissionCubit.startRecording,
                      child: const Text('Start recording'),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state is AudioTransmissionRecordingState ? audioTransmissionCubit.stopRecording : null,
                      child: const Text('Stop recording'),
                    ),
                  ),
                ],
              ),
              if (state is AudioTransmissionResultState)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Text(
                    state.decodedMessage,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
