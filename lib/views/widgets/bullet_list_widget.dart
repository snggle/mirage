import 'package:flutter/material.dart';

class BulletListWidget extends StatelessWidget {
  final List<String> points;

  const BulletListWidget({
    required this.points,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points
          .map(
            (String value) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 5.0, right: 6.0),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
