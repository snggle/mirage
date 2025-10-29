import 'package:flutter/material.dart';
import 'package:mirage/views/pages/tutorial_page.dart';

class IdlePage extends StatefulWidget {
  final bool pubkeyExistsBool;
  final VoidCallback onOpenPubkeyUpload;

  const IdlePage({
    required this.pubkeyExistsBool,
    required this.onOpenPubkeyUpload,
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
          ],
          if (widget.pubkeyExistsBool) ...<Widget>[
            const SizedBox(height: 30),
            const Text('Mirage is waiting for your actions on MetaMask', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 400,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => TutorialPage.walletConnect()),
                      );
                    },
                    child: const Text(
                      'Connect to MetaMask or Reset MetaMask',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 400,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => TutorialPage.hardReset()),
                      );
                    },
                    child: const Text(
                      'Send Transaction on MetaMask',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          if (widget.pubkeyExistsBool == false) ...<Widget>[
            ElevatedButton(onPressed: widget.onOpenPubkeyUpload, child: const Text('Connect wallet')),
            const SizedBox(height: 50),
          ],
          if (widget.pubkeyExistsBool) ...<Widget>[
            ElevatedButton(onPressed: widget.onOpenPubkeyUpload, child: const Text('Change wallet')),
            const SizedBox(height: 50),
          ],
        ],
      ),
    );
  }
}
