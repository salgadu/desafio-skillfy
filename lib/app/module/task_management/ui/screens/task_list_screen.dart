import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desafio_skillfy/app/module/task_management/controller/task_controller.dart';
import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/category_filter.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final controller = context.read<TaskController>();
    controller.setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, controller, child) {
        final tasks = controller.tasks;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Minhas Tarefas'),
            actions: [
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.clear_all),
                tooltip: 'Limpar Filtros',
                onPressed: () {
                  controller.clearFilters();
                  _searchController.clear();
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.refresh,
              ),
            ],
          ),
          body: Column(
            children: [
              // Barra de busca
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar tarefas...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Filtros
              if (_showFilters) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CategoryFilter(
                    categories: controller.categories,
                    selectedCategory: controller.categoryFilter,
                    onCategorySelected: (category) {
                      controller.setCategoryFilter(category);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildFilterChips(context, controller),
                const Divider(),
              ],

              // Contador de tarefas
              if (tasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${tasks.length} tarefa(s) encontrada(s)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      if (controller.statusFilter != null ||
                          controller.priorityFilter != null ||
                          controller.categoryFilter != null ||
                          controller.searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            controller.clearFilters();
                            _searchController.clear();
                          },
                          child: const Text('Limpar filtros'),
                        ),
                    ],
                  ),
                ),

              // Lista de tarefas
              Expanded(child: _buildTasksList(context, controller, tasks)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).pushNamed('/task_form');
            },
            icon: const Icon(Icons.add),
            label: const Text('Nova Tarefa'),
          ),
        );
      },
    );
  }

  Widget _buildTasksList(
    BuildContext context,
    TaskController controller,
    List<Task> tasks,
  ) {
    if (controller.state == TaskControllerState.loading && tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.state == TaskControllerState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage ??
                    'Ocorreu um erro ao carregar as tarefas.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.refresh,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.isNotEmpty ||
                        controller.statusFilter != null ||
                        controller.priorityFilter != null ||
                        controller.categoryFilter != null
                    ? 'Nenhuma tarefa encontrada com os filtros aplicados.'
                    : 'Nenhuma tarefa cadastrada ainda.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                controller.searchQuery.isNotEmpty ||
                        controller.statusFilter != null ||
                        controller.priorityFilter != null ||
                        controller.categoryFilter != null
                    ? 'Tente ajustar os filtros ou criar uma nova tarefa.'
                    : 'Comece criando sua primeira tarefa!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/task_form');
                },
                icon: const Icon(Icons.add),
                label: const Text('Criar Tarefa'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final bool canDismiss = task.id != null;

          // CORRIGIDO: Verifica se a tarefa pode ser marcada como concluída
          final bool canComplete =
              task.status != TaskStatus.completed &&
              task.status != TaskStatus.cancelled;

          return Dismissible(
            key: Key(task.id ?? task.title + index.toString()),
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              color: canDismiss && canComplete ? Colors.green : Colors.grey,
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Concluir',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: canDismiss ? Colors.red : Colors.grey,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Excluir',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.delete, color: Colors.white),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              if (!canDismiss) return false;

              if (direction == DismissDirection.startToEnd) {
                // CORRIGIDO: Só permite concluir se a tarefa não estiver finalizada
                if (!canComplete) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tarefa ${task.status == TaskStatus.completed ? "já está concluída" : "foi cancelada"} e não pode ser alterada.',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                  return false;
                }

                // Marcar como concluída
                final updatedTask = task.copyWith(
                  status: TaskStatus.completed,
                  completedAt: DateTime.now(),
                );
                await controller.updateTask(updatedTask);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarefa marcada como concluída!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                return false;
              } else {
                // Confirmar exclusão
                return await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Confirmar Exclusão',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      content: Text(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        'Tem certeza que deseja excluir a tarefa "${task.title}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Excluir'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            onDismissed: (direction) async {
              if (direction == DismissDirection.endToStart) {
                await controller.deleteTask(task.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarefa excluída com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: TaskCard(
              task: task,
              onTap: () {
                Navigator.of(context).pushNamed('/task_form', arguments: task);
              },
              onStatusChanged: (newStatus) async {
                if (task.id != null) {
                  // CORRIGIDO: Impede mudanças de status para tarefas finalizadas
                  if (task.status == TaskStatus.completed ||
                      task.status == TaskStatus.cancelled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tarefa ${task.status == TaskStatus.completed ? "concluída" : "cancelada"} não pode ser alterada.',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final updatedTask = task.copyWith(
                    status: newStatus,
                    // Define completedAt se estiver marcando como concluída
                    completedAt: newStatus == TaskStatus.completed
                        ? DateTime.now()
                        : (newStatus == TaskStatus.completed
                              ? null
                              : task.completedAt),
                  );
                  await controller.updateTask(updatedTask);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Status alterado para ${newStatus.displayName}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              showActions: canDismiss,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, TaskController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildDropdownFilter<TaskPriority>(
            context: context,
            hint: 'Prioridade',
            items: TaskPriority.values,
            selectedValue: controller.priorityFilter,
            onChanged: (value) {
              controller.setPriorityFilter(value);
            },
            itemBuilder: (priority) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag, size: 16, color: _getPriorityColor(priority)),
                const SizedBox(width: 4),
                Text(priority.displayName),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildDropdownFilter<TaskStatus>(
            context: context,
            hint: 'Status',
            items: TaskStatus.values,
            selectedValue: controller.statusFilter,
            onChanged: (value) {
              controller.setStatusFilter(value);
            },
            itemBuilder: (status) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(status),
                  size: 16,
                  color: _getStatusColor(status),
                ),
                const SizedBox(width: 4),
                Text(status.displayName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter<T>({
    required BuildContext context,
    required String hint,
    required List<T> items,
    T? selectedValue,
    required ValueChanged<T?> onChanged,
    required Widget Function(T) itemBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selectedValue != null
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selectedValue != null
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedValue,
          hint: Text(
            hint,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selectedValue != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: selectedValue != null ? FontWeight.w600 : null,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: selectedValue != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onChanged: onChanged,
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text(
                'Todos',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ...items.map<DropdownMenuItem<T>>((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: itemBuilder(value),
              );
            }),
          ],
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.pending;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }
}
