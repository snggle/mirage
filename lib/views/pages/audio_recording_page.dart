import 'package:flutter/material.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_recorded_state.dart';
import 'package:mirage/views/pages/audio_result_widget.dart';
import 'package:mirage/views/pages/request_description_widget.dart';

class AudioRecordingPage extends StatefulWidget {
  final MainPageEnabledState mainPageState;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCompleted;

  const AudioRecordingPage({
    required this.mainPageState,
    required this.onSubmitted,
    required this.onCompleted,
    super.key,
  });

  @override
  State<AudioRecordingPage> createState() => _AudioRecordingPageState();
}

class _AudioRecordingPageState extends State<AudioRecordingPage> {
  bool _showAdditionalText = false;

  @override
  void didUpdateWidget(covariant AudioRecordingPage oldWidget) {
    if (_showAdditionalText == true && widget.mainPageState is MainPageDisabledState) {
      _toggleTextVisibility();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    List<String>? description = widget.mainPageState.description;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.mainPageState.repeatedAttemptBool) ...<Widget>[
              const Text('Invalid message. Please try again.', style: TextStyle(color: Colors.red)),
              const SizedBox(
                height: 10,
              ),
            ],
            Text(widget.mainPageState.title, style: const TextStyle(fontSize: 20)),
            if (description.isNotEmpty) RequestDescriptionWidget(description: description),
            const SizedBox(height: 10),
            if (widget.mainPageState is MainPageRecordedState == false) ...<Widget>[
              ElevatedButton(
                onPressed: _toggleTextVisibility,
                child: const Text('Play audio'),
              ),
              const SizedBox(height: 10),
              if (_showAdditionalText) SelectableText(widget.mainPageState.audioRequestData),
              const SizedBox(height: 20),
              TextFormField(
                controller: textEditingController,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => widget.onSubmitted(textEditingController.text),
                label: const Text('Submit'),
                icon: const Icon(Icons.navigate_next_outlined),
              ),
              const SizedBox(height: 40),
            ],
            if (widget.mainPageState is MainPageRecordedState) ...<Widget>[
              AudioResultWidget(
                recordValidBool: (widget.mainPageState as MainPageRecordedState).recordValidBool,
                onCompleted: widget.onCompleted,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleTextVisibility() {
    setState(() {
      _showAdditionalText = _showAdditionalText == false;
    });
  }
}
