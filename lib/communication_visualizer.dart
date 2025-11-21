import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirage/blocs/visualizer_cubit/visualizer_cubit.dart';
import 'package:mirage/blocs/visualizer_cubit/visualizer_phase.dart';
import 'package:mirage/blocs/visualizer_cubit/visualizer_state.dart';
import 'package:mirage/config/locator.dart';
import 'package:mirage/views/widgets/blinking_icon.dart';
import 'package:mirage/visualizer_animated_icons.dart';
import 'package:mirage/visualizer_app_logo_icons.dart';

class CommunicationVisualizer extends StatefulWidget {
  final bool walletConnectedBool;

  const CommunicationVisualizer({
    required this.walletConnectedBool,
    super.key,
  });

  @override
  State<CommunicationVisualizer> createState() => _CommunicationVisualizerState();
}

class _CommunicationVisualizerState extends State<CommunicationVisualizer> {
  final VisualizerCubit _visualizerCubit = globalLocator<VisualizerCubit>();
  bool _micIconStaticBool = false;
  bool _speakerIconStaticBool = false;

  // The animated icons are defined inside this class, so that their animation can be restarted with each state reload using _restartAnimatedIcons()
  final Image _micDynamicIcon = Image.asset(
    'assets/visualizer/mic_dynamic.webp',
    fit: BoxFit.cover,
  );
  final Image _speakerDynamicIcon = Image.asset(
    'assets/visualizer/speaker_dynamic.webp',
    fit: BoxFit.cover,
  );
  final Image _micStaticIcon = Image.asset(
    'assets/visualizer/mic_static.webp',
    fit: BoxFit.cover,
  );
  final Image _speakerStaticIcon = Image.asset(
    'assets/visualizer/speaker_static.webp',
    fit: BoxFit.cover,
  );
  final Image _audioWaveIcon = Image.asset(
    'assets/visualizer/audio_wave.webp',
    fit: BoxFit.cover,
  );
  final Image _dataReadyIcon = Image.asset(
    'assets/visualizer/data_ready.webp',
    fit: BoxFit.cover,
  );

  @override
  void initState() {
    super.initState();
    _restartAnimationTimer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VisualizerCubit, VisualizerState>(
      bloc: _visualizerCubit,
      listenWhen: (VisualizerState prev, VisualizerState curr) => prev.phase != curr.phase,
      listener: (BuildContext context, VisualizerState state) => _restartAnimatedIcons(),
      builder: (BuildContext context, VisualizerState state) {
        final VisualizerAnimatedIcons visualizerAnimatedIcons = _getIconsForPhase(state);
        return Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (state.phase == VisualizerPhase.initial && widget.walletConnectedBool)
                  BlinkingIcon(child: VisualizerAppLogoIcons.metamaskIcon)
                else
                  VisualizerAppLogoIcons.metamaskIcon,
                SizedBox(width: 150, height: 40, child: visualizerAnimatedIcons.webConnectionIcon),
                VisualizerAppLogoIcons.mirageIcon,
                SizedBox(
                  width: 150,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 90,
                          height: 40,
                          child: visualizerAnimatedIcons.audioWaveIcon,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(width: 40, height: 40, child: visualizerAnimatedIcons.mirageDeviceIcon),
                          SizedBox(width: 40, height: 40, child: visualizerAnimatedIcons.snggleDeviceIcon),
                        ],
                      ),
                    ],
                  ),
                ),
                if (state.phase == VisualizerPhase.recording)
                  BlinkingIcon(child: VisualizerAppLogoIcons.snggleIcon)
                else
                  VisualizerAppLogoIcons.snggleIcon,
              ],
            ),
          ],
        );
      },
    );
  }

  void _restartAnimatedIcons() {
    _restartAnimationTimer();
    setState(() {
      _speakerDynamicIcon.image.evict();
      _micDynamicIcon.image.evict();
      _audioWaveIcon.image.evict();
      _dataReadyIcon.image.evict();
    });
  }

  void _restartAnimationTimer() {
    setState(() {
      _micIconStaticBool = false;
      _speakerIconStaticBool = false;
    });

    Future<void>.delayed(const Duration(milliseconds: 2480), () {
      if (mounted) {
        setState(() {
          _micIconStaticBool = true;
          _speakerIconStaticBool = true;
        });
      }
    });
  }

  VisualizerAnimatedIcons _getIconsForPhase(VisualizerState state) {
    switch (state.phase) {
      case VisualizerPhase.initial:
        return const VisualizerAnimatedIcons(
          webConnectionIcon: null,
          mirageDeviceIcon: null,
          audioWaveIcon: null,
          snggleDeviceIcon: null,
        );
      case VisualizerPhase.readyToEmit:
        return VisualizerAnimatedIcons(
          webConnectionIcon: null,
          mirageDeviceIcon: _speakerIconStaticBool ? _speakerStaticIcon : _speakerDynamicIcon,
          audioWaveIcon: const SizedBox(),
          snggleDeviceIcon: _micIconStaticBool ? _micStaticIcon : _micDynamicIcon,
        );
      case VisualizerPhase.emitting:
        return VisualizerAnimatedIcons(
          webConnectionIcon: null,
          mirageDeviceIcon: _speakerStaticIcon,
          audioWaveIcon: _audioWaveIcon,
          snggleDeviceIcon: _micStaticIcon,
        );
      case VisualizerPhase.recording:
        return VisualizerAnimatedIcons(
          webConnectionIcon: null,
          mirageDeviceIcon: _micIconStaticBool ? _micStaticIcon : _micDynamicIcon,
          audioWaveIcon: const SizedBox(),
          snggleDeviceIcon: _speakerIconStaticBool ? _speakerStaticIcon : _speakerDynamicIcon,
        );
      case VisualizerPhase.decoding:
        return VisualizerAnimatedIcons(
          webConnectionIcon: null,
          mirageDeviceIcon: _micStaticIcon,
          audioWaveIcon: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
            child: _audioWaveIcon,
          ),
          snggleDeviceIcon: _speakerStaticIcon,
        );
      case VisualizerPhase.dataReady:
        return VisualizerAnimatedIcons(
          webConnectionIcon: _dataReadyIcon,
          mirageDeviceIcon: null,
          audioWaveIcon: null,
          snggleDeviceIcon: null,
        );
      case VisualizerPhase.noConnections:
        return const VisualizerAnimatedIcons(
          webConnectionIcon: null,
          mirageDeviceIcon: null,
          audioWaveIcon: null,
          snggleDeviceIcon: null,
        );
    }
  }
}
