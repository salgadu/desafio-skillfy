import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';
import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/priority_badge.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/category_chip.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/status_indicator.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final Function(TaskStatus)? onStatusChanged;
  final bool showActions;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChanged,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOverdue =
        task.deadline.isBefore(DateTime.now()) &&
        task.status != TaskStatus.completed &&
        task.status != TaskStatus.cancelled;

    // CORRIGIDO: Tarefas finalizadas (concluídas ou canceladas) não podem ser alteradas
    final canChangeStatus =
        task.status != TaskStatus.completed &&
        task.status != TaskStatus.cancelled;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue
            ? BorderSide(color: Colors.red.shade300, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com título e status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: task.status == TaskStatus.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.status == TaskStatus.completed
                                    ? colorScheme.onSurfaceVariant
                                    : null,
                              ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusIndicator(
                    status: task.status,
                    showLabel: true,
                    showIcon: true,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Badges e informações
              Row(
                children: [
                  PriorityBadge(priority: task.priority),
                  const SizedBox(width: 8),
                  CategoryChip(
                    category: task.category,
                    isSelected: false,
                    size: CategoryChipSize.small,
                  ),
                  const Spacer(),
                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 14,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Atrasada',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Informações de tempo
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.estimatedDuration} min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isOverdue
                        ? Colors.red
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.MMMd().add_jm().format(task.deadline),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOverdue
                          ? Colors.red
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isOverdue ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),

              // Mostrar data de conclusão se a tarefa estiver concluída
              if (task.status == TaskStatus.completed &&
                  task.completedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Concluída em ${DateFormat.MMMd().add_jm().format(task.completedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // Ações (se habilitadas e a tarefa puder ser alterada)
              if (showActions &&
                  onStatusChanged != null &&
                  canChangeStatus) ...[
                const SizedBox(height: 12),
                const Divider(),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    List<Widget> actions = [];

    // CORRIGIDO: Lógica de ações baseada no status atual
    switch (task.status) {
      case TaskStatus.pending:
        actions = [
          _buildActionButton(
            context,
            icon: Icons.play_arrow,
            label: 'Iniciar',
            color: Colors.blue,
            onPressed: () => onStatusChanged!(TaskStatus.inProgress),
          ),
          _buildActionButton(
            context,
            icon: Icons.check,
            label: 'Concluir',
            color: Colors.green,
            onPressed: () => onStatusChanged!(TaskStatus.completed),
          ),
          _buildActionButton(
            context,
            icon: Icons.cancel,
            label: 'Cancelar',
            color: Colors.red,
            onPressed: () => onStatusChanged!(TaskStatus.cancelled),
          ),
        ];
        break;

      case TaskStatus.inProgress:
        actions = [
          _buildActionButton(
            context,
            icon: Icons.pause,
            label: 'Pausar',
            color: Colors.orange,
            onPressed: () => onStatusChanged!(TaskStatus.pending),
          ),
          _buildActionButton(
            context,
            icon: Icons.check,
            label: 'Concluir',
            color: Colors.green,
            onPressed: () => onStatusChanged!(TaskStatus.completed),
          ),
          _buildActionButton(
            context,
            icon: Icons.cancel,
            label: 'Cancelar',
            color: Colors.red,
            onPressed: () => onStatusChanged!(TaskStatus.cancelled),
          ),
        ];
        break;

      case TaskStatus.completed:
      case TaskStatus.cancelled:
        // Tarefas finalizadas não têm ações disponíveis
        actions = [];
        break;
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions,
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
