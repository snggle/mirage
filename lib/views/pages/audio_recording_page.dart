import 'package:flutter/material.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_disabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_enabled_state.dart';
import 'package:mirage/blocs/main_page_cubit/states/main_page_recorded_state.dart';
import 'package:mirage/views/pages/request_data_widget.dart';
import 'package:mirage/views/pages/request_description_widget.dart';

class AudioRecordingPage extends StatefulWidget {
  final MainPageEnabledState mainPageState;
  final ValueChanged<List<String>> onSubmitted;
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
  late List<TextFormField> textFields;

  @override
  void initState() {
    textFields = widget.mainPageState.inputStructure
        .map((String label) => TextFormField(
              decoration: InputDecoration(labelText: label),
              controller: TextEditingController(),
            ))
        .toList();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AudioRecordingPage oldWidget) {
    if (_showAdditionalText == true && widget.mainPageState is MainPageDisabledState) {
      _toggleTextVisibility();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
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
              if (_showAdditionalText)
                RequestDataWidget(
                  audioRequestData: widget.mainPageState.audioRequestData,
                ),
              const SizedBox(height: 20),
              Column(
                children: textFields,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => widget.onSubmitted(_mapTextFieldsToList(textFields)),
                label: const Text('Submit'),
                icon: const Icon(Icons.navigate_next_outlined),
              ),
              const SizedBox(height: 40),
            ],
            if (widget.mainPageState is MainPageRecordedState) ...<Widget>[
              const Text('The message was recorded. You can proceed by clicking the button'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: widget.onCompleted,
                label: const Text('Proceed'),
                icon: const Icon(Icons.navigate_next_outlined),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _mapTextFieldsToList(List<TextFormField> textFields) {
    return textFields.map((TextFormField e) => e.controller!.text).toList();
  }

  void _toggleTextVisibility() {
    setState(() {
      _showAdditionalText = _showAdditionalText == false;
    });
  }
}
