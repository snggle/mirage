import 'package:mirage/blocs/visualizer_cubit/visualizer_phase.dart';

class VisualizerState {
  final VisualizerPhase phase;

  const VisualizerState({required this.phase});

  VisualizerState copyWith({VisualizerPhase? phase}) {
    return VisualizerState(phase: phase ?? this.phase);
  }

  factory VisualizerState.initial() => const VisualizerState(phase: VisualizerPhase.initial);
  factory VisualizerState.readyToEmit() => const VisualizerState(phase: VisualizerPhase.readyToEmit);
  factory VisualizerState.emitting() => const VisualizerState(phase: VisualizerPhase.emitting);
  factory VisualizerState.recording() => const VisualizerState(phase: VisualizerPhase.recording);
  factory VisualizerState.decoding() => const VisualizerState(phase: VisualizerPhase.decoding);
  factory VisualizerState.dataReady() => const VisualizerState(phase: VisualizerPhase.dataReady);
  factory VisualizerState.noConnections() => const VisualizerState(phase: VisualizerPhase.noConnections);
}