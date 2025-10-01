import 'package:flutter/cupertino.dart';

class GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle? textStyle;
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    required this.gradient,
    this.textStyle,
    this.overflow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: RadialGradient(
        radius: 8,
        center: Alignment.topLeft,
        colors: gradient.colors,
      ).createShader,
      child: Text(
        text,
        overflow: overflow,
        style: textStyle,
      ),
    );
  }
}
