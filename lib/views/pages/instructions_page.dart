import 'package:flutter/material.dart';
import 'package:mirage/views/pages/tutorial_page.dart';

class InstructionsPage extends StatelessWidget {
  const InstructionsPage({
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
              'Metamask instructions',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: buttonWidth,
              child: const OutlinedButton(
                onPressed: null,
                child: Text(
                  'Connect to MetaMask',
                  style: TextStyle(color: Colors.blue),
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
