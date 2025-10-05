import 'package:flutter/material.dart';

class ChameleonMascot extends StatelessWidget {
  const ChameleonMascot({super.key, required this.statusColor});

  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.emoji_nature, color: statusColor, size: 64);
  }
}
