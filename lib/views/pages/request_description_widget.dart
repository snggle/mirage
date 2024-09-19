import 'package:flutter/material.dart';

class RequestDescriptionWidget extends StatelessWidget {
  final List<String> description;

  const RequestDescriptionWidget({
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: description.map((String value) => Text(value, style: const TextStyle(fontSize: 15))).toList(),
    );
  }
}
