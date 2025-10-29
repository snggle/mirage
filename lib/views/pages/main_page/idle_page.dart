import 'package:flutter/material.dart';
import 'package:mirage/views/pages/tutorial_page.dart';

class IdlePage extends StatefulWidget {
  final bool pubkeyExistsBool;

  const IdlePage({
    required this.pubkeyExistsBool,
    super.key,
  });

  @override
  State<IdlePage> createState() => _IdlePageState();
}

class _IdlePageState extends State<IdlePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (widget.pubkeyExistsBool == false) ...<Widget>[
            const SizedBox(height: 60),
            const Text('Wallet not connected', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => TutorialPage.walletConnect()),
                );
              },
              child: const Text('Get started!'),
            ),
            const SizedBox(height: 50),
          ],
          if (widget.pubkeyExistsBool) ...<Widget>[
            const SizedBox(height: 60),
            const Text('Mirage is waiting for your actions on MetaMask', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 50),
          ],
        ],
      ),
    );
  }
}
