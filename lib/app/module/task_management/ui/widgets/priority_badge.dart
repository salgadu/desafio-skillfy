import 'package:desafio_skillfy/app/core/ui/theme/app_colors.dart';
import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';
import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool showLabel;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(
      context,
    ).extension<AppColors>()!; // Adicionar esta linha
    final config = _getPriorityConfig(priority, appColors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              config.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: config.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _PriorityConfig _getPriorityConfig(
    TaskPriority priority,
    AppColors appColors,
  ) {
    // Modificar assinatura
    switch (priority) {
      case TaskPriority.high:
        return _PriorityConfig(
          color: appColors.highPriority,
          label: 'Alta',
        ); // Usar appColors
      case TaskPriority.medium:
        return _PriorityConfig(
          color: appColors.mediumPriority,
          label: 'Média',
        ); // Usar appColors
      case TaskPriority.low:
        return _PriorityConfig(
          color: appColors.lowPriority,
          label: 'Baixa',
        ); // Usar appColors
    }
  }
}

class _PriorityConfig {
  final Color color;
  final String label;

  _PriorityConfig({required this.color, required this.label});
}
