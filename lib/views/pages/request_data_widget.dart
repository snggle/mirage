import 'package:flutter/material.dart';

class RequestDataWidget extends StatelessWidget {
  final Map<String, String> audioRequestData;

  const RequestDataWidget({
    required this.audioRequestData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: ListView(
            shrinkWrap: true,
            children: audioRequestData.entries.map((MapEntry<String, String> entry) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${entry.key}:',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectableText(
                      entry.value,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
