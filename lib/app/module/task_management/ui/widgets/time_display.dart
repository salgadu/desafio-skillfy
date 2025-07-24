// widgets/task/time_display.dart
import 'package:desafio_skillfy/app/core/utils/utils.dart';
import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final DateTime dateTime;
  final int? duration; // em minutos
  final bool showDate;
  final bool showDuration;
  final bool isDeadline;

  const TimeDisplay({
    super.key,
    required this.dateTime,
    this.duration,
    this.showDate = true,
    this.showDuration = false,
    this.isDeadline = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = isDeadline && dateTime.isBefore(now);
    final textColor = isOverdue
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isDeadline ? Icons.schedule : Icons.access_time,
          size: 14,
          color: textColor,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDate)
              Text(
                Utils.formatDateTime(dateTime),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            if (showDuration && duration != null)
              Text(
                Utils.formatDuration(duration!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
