// widgets/common/custom_fab.dart
import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final bool isExtended;
  final String? label;

  const CustomFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.isExtended = false,
    this.label,
  });

  const CustomFAB.extended({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.tooltip,
  }) : isExtended = true;

  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
