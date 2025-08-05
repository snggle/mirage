import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/audio_supervisor_cubit/audio_supervisor_state.dart';

class AudioSupervisorCubit extends Cubit<AudioSupervisorState> {
  AudioSupervisorCubit() : super(AudioSupervisorState());

  void refresh() {
    emit(AudioSupervisorState());
  }
}
