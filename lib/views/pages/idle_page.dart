import 'package:flutter/material.dart';

class IdlePage extends StatelessWidget {
  final bool reconnectNeededBool;

  const IdlePage({required this.reconnectNeededBool, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 30),
        const Text(
          'Mirage is waiting for your actions on MetaMask',
        ),
        if (reconnectNeededBool) ...<Widget>[
          const SizedBox(height: 10),
          const Text(
            'Connect your wallet to MetaMask',
          ),
        ],
      ],
    );
  }
}
