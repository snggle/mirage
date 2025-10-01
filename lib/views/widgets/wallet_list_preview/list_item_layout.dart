import 'package:flutter/material.dart';

class ListItemLayout extends StatelessWidget {
  static const Size listItemSize = Size(double.infinity, 95);

  final Widget iconWidget;
  final Widget? titleWidget;
  final Widget? subtitleWidget;

  const ListItemLayout({
    required this.iconWidget,
    this.titleWidget,
    this.subtitleWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      height: listItemSize.height,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F3F3), width: 0.6),
        ),
      ),
      child: Row(
        children: <Widget>[
          iconWidget,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (titleWidget != null) ...<Widget>[
                  titleWidget!,
                ],
                if (subtitleWidget != null) subtitleWidget!,
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
