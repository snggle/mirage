import 'package:flutter/material.dart';
import 'package:mirage/views/pages/tutorial_page.dart';

class ExtraActionsPage extends StatelessWidget {
  final bool pubkeyExistsBool;
  final VoidCallback onOpenPubkeyUpload;

  const ExtraActionsPage({
    required this.pubkeyExistsBool,
    required this.onOpenPubkeyUpload,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth / 2;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 50),
            const Text(
              'Already connected to MetaMask?',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: buttonWidth,
              child: OutlinedButton(
                onPressed: onOpenPubkeyUpload,
                child: Text(
                  pubkeyExistsBool ? 'Change pubkey' : 'Upload pubkey',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: buttonWidth,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => TutorialPage.hardReset()),
                  );
                },
                child: const Text(
                  'Reset MetaMask',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
