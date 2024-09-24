import 'package:flutter/material.dart';

class AudioResultWidget extends StatelessWidget {
  final bool recordValidBool;
  final VoidCallback onCompleted;

  const AudioResultWidget({
    required this.recordValidBool,
    required this.onCompleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(recordValidBool ? 'The message was recorded. You can proceed by clicking the button' : 'Invalid record. Please try again'),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onCompleted,
          label: Text(recordValidBool ? 'Proceed' : 'Try again'),
          icon: const Icon(Icons.navigate_next_outlined),
        ),
      ],
    );
  }
}
