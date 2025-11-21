import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/visualizer_cubit/visualizer_state.dart';

class VisualizerCubit extends Cubit<VisualizerState> {
  VisualizerCubit() : super(VisualizerState.initial());

  void switchToInitial() {
    emit(VisualizerState.initial());
  }

  void switchToReadyEmit() {
    emit(VisualizerState.readyToEmit());
  }

  void switchToEmitting() {
    emit(VisualizerState.emitting());
  }

  void switchToRecording() {
    emit(VisualizerState.recording());
  }

  void switchToDecoding() {
    emit(VisualizerState.decoding());
  }

  void switchToDataReady() {
    emit(VisualizerState.dataReady());
  }

  void switchToNoConnections() {
    emit(VisualizerState.noConnections());
  }
}
