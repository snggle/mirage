import 'package:flutter/material.dart';

class BlinkingIcon extends StatefulWidget {
  const BlinkingIcon({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<BlinkingIcon> createState() => _BlinkingIconState();
}

class _BlinkingIconState extends State<BlinkingIcon> {
  final double minOpacity = 0.0;
  final Duration period = const Duration(milliseconds: 1600);
  bool _visibleBool = true;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: _visibleBool ? 1.0 : minOpacity,
        end: _visibleBool ? 1.0 : minOpacity,
      ),
      duration: period ~/ 2,
      builder: (BuildContext context, double value, Widget? child) => Opacity(
        opacity: value,
        child: child,
      ),
      child: widget.child,
    );
  }

  Future<void> _tick() async {
    while (mounted) {
      await Future<void>.delayed(period ~/ 2);
      if (mounted == false) {
        return;
      }
      setState(() => _visibleBool = _visibleBool == false);
    }
  }
}
