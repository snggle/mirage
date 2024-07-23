import 'package:mirage/blocs/audio_transmission_cubit/a_audio_transmission_state.dart';

class AudioTransmissionResultState extends AAudioTransmissionState {
  final String decodedMessage;

  AudioTransmissionResultState({required this.decodedMessage});

  @override
  List<Object?> get props => <Object>[decodedMessage];
}
