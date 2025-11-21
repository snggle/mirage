import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class VisualizerAppLogoIcons {
  static Widget metamaskIcon = _buildIcon('assets/visualizer/metamask.svg', size: 40);
  static Widget mirageIcon = _buildIcon('assets/visualizer/mirage.svg');
  static Widget snggleIcon = _buildIcon('assets/visualizer/snggle.png');

  static Widget _buildIcon(String assetPath, {double size = 50}) {
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
      );
    }
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
