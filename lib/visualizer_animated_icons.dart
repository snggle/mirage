import 'package:flutter/material.dart';

class VisualizerAnimatedIcons {
  final Widget? _webConnectionIcon;
  final Widget? mirageDeviceIcon;
  final Widget? _audioWaveIcon;
  final Widget? _snggleDeviceIcon;

  const VisualizerAnimatedIcons({
    Widget? webConnectionIcon,
    this.mirageDeviceIcon,
    Widget? audioWaveIcon,
    Widget? snggleDeviceIcon,
  })  : _webConnectionIcon = webConnectionIcon,
        _audioWaveIcon = audioWaveIcon,
        _snggleDeviceIcon = snggleDeviceIcon;

  Widget get webConnectionIcon => _webConnectionIcon ?? _placeholder;

  Widget get audioWaveIcon => _audioWaveIcon ?? _placeholder;

  Widget? get snggleDeviceIcon {
    if (_snggleDeviceIcon == null) {
      return null;
    }

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
      child: _snggleDeviceIcon,
    );
  }

  Widget get _placeholder => const Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 100,
          height: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFD2D6E1),
            ),
          ),
        ),
      );
}
