import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  final bool reconnectNeededBool;

  const EmptyPage({required this.reconnectNeededBool, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 30),
        const Text(
          'Trezor Virtualization',
        ),
        if (reconnectNeededBool) ...<Widget>[
          const SizedBox(height: 10),
          const Text(
            'Connect wallet',
          ),
        ],
      ],
    );
  }
}
