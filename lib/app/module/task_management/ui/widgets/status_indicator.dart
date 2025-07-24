import 'package:desafio_skillfy/app/core/ui/theme/app_colors.dart';
import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';
import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final TaskStatus status;
  final bool showLabel;
  final bool showIcon;

  const StatusIndicator({
    super.key,
    required this.status,
    this.showLabel = true,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final config = _getStatusConfig(status, appColors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(config.icon, size: 14, color: config.textColor),
            if (showLabel) const SizedBox(width: 4),
          ],
          if (!showIcon && !showLabel) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: config.textColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
          if (showLabel)
            Text(
              config.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: config.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(TaskStatus status, AppColors appColors) {
    switch (status) {
      case TaskStatus.pending:
        return _StatusConfig(
          backgroundColor: Colors.orange.shade100,
          textColor: Colors.orange.shade800,
          icon: Icons.pending,
          label: 'Pendente',
        );
      case TaskStatus.inProgress:
        return _StatusConfig(
          backgroundColor: Colors.blue.shade100,
          textColor: Colors.blue.shade800,
          icon: Icons.play_circle_outline,
          label: 'Em Progresso',
        );
      case TaskStatus.completed:
        return _StatusConfig(
          backgroundColor: Colors.green.shade100,
          textColor: Colors.green.shade800,
          icon: Icons.check_circle,
          label: 'Concluída',
        );
      case TaskStatus.cancelled:
        return _StatusConfig(
          backgroundColor: Colors.red.shade100,
          textColor: Colors.red.shade800,
          icon: Icons.cancel,
          label: 'Cancelada',
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final String label;

  _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.label,
  });
}
