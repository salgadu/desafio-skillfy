import 'package:desafio_skillfy/app/core/ui/theme/theme_controller.dart';
import 'package:desafio_skillfy/app/module/task_management/controller/task_controller.dart';
import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_suggestion.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/productivity_chart%20.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/task_card.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/time_suggestions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<TaskController>();
      if (controller.state == TaskControllerState.idle) {
        controller.refresh();
      }
    });
  }

  List<Task> _getTasksForDashboard(TaskController controller) {
    final actionableTasks = controller.allTasks
        .where(
          (task) =>
              task.status != TaskStatus.completed &&
              task.status != TaskStatus.cancelled,
        )
        .toList();

    final highPriority = actionableTasks
        .where((task) => task.priority == TaskPriority.high)
        .toList();
    final mediumPriority = actionableTasks
        .where((task) => task.priority == TaskPriority.medium)
        .toList();
    final lowPriority = actionableTasks
        .where((task) => task.priority == TaskPriority.low)
        .toList();

    highPriority.sort((a, b) => a.deadline.compareTo(b.deadline));
    mediumPriority.sort((a, b) => a.deadline.compareTo(b.deadline));
    lowPriority.sort((a, b) => a.deadline.compareTo(b.deadline));

    final dashboardTasks = <Task>[];
    dashboardTasks.addAll(highPriority);
    dashboardTasks.addAll(mediumPriority);
    dashboardTasks.addAll(lowPriority);

    return dashboardTasks.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Consumer2<TaskController, ThemeController>(
      builder: (context, taskController, themeController, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            title: const Text('Tarefinha '),
            leading: IconButton(
              onPressed: () => themeController.toggleTheme(),
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              tooltip: Theme.of(context).brightness == Brightness.dark
                  ? 'Ativar tema claro'
                  : 'Ativar tema escuro',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => taskController.refresh(),
                tooltip: 'Atualizar dados',
              ),
            ],
          ),
          body: _buildBody(context, taskController, colorScheme),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    TaskController controller,
    ColorScheme colorScheme,
  ) {
    if (controller.state == TaskControllerState.loading &&
        controller.allTasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.state == TaskControllerState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage ??
                    'Ocorreu um erro ao carregar os dados.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refresh(),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final dashboardTasks = _getTasksForDashboard(controller);
    final genericSuggestions = controller.genericTimeSuggestions;

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildGreeting(context),
              const SizedBox(height: 24),
              _buildSummaryRow(context, controller),
              const SizedBox(height: 24),
              _buildProductivityChart(context, controller),
              const SizedBox(height: 24),
              _buildNextTasksSection(context, dashboardTasks, controller),
              const SizedBox(height: 24),
              _buildTimeSuggestions(context, genericSuggestions),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour >= 5 && hour < 12) {
      greeting = 'Bom dia! ☀️';
    } else if (hour >= 12 && hour < 18) {
      greeting = 'Boa tarde! 🌤️';
    } else {
      greeting = 'Boa noite! 🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Veja o resumo de suas atividades.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, TaskController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Resumo'),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  context,
                  'Pendentes',
                  controller.pendingTasks.toString(),
                  Icons.pending_actions,
                  Theme.of(context).colorScheme.primary,
                ),
                _buildSummaryItem(
                  context,
                  'Em Progresso',
                  controller.inProgressTasks.toString(),
                  Icons.play_circle_outline,
                  Colors.blue.shade600,
                ),
                _buildSummaryItem(
                  context,
                  'Concluídas',
                  controller.completedTasks.toString(),
                  Icons.check_circle_outline,
                  Colors.green.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProductivityChart(
    BuildContext context,
    TaskController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Produtividade da Semana'),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ProductivityChart(weeklyData: controller.weeklyProductivity),
          ),
        ),
      ],
    );
  }

  Widget _buildNextTasksSection(
    BuildContext context,
    List<Task> tasksToShow,
    TaskController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Próximas Tarefas'),
        if (tasksToShow.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma tarefa pendente!',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Você está em dia com suas atividades.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...tasksToShow.map(
            (task) => TaskCard(
              task: task,
              onTap: () {
                Navigator.of(context).pushNamed('/task_form', arguments: task);
              },
              onStatusChanged: (newStatus) async {
                if (task.id != null) {
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
                    completedAt: newStatus == TaskStatus.completed
                        ? DateTime.now()
                        : task.completedAt,
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
              showActions: task.id != null,
            ),
          ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.list_alt),
            label: const Text('Ver todas as tarefas'),
            onPressed: () {
              Navigator.of(context).pushNamed('/task_list');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSuggestions(
    BuildContext context,
    List<SuggestedTime> suggestions,
  ) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Sugestões de Horários'),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Horários Recomendados',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Use essas sugestões como referência ao criar novas tarefas:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                TimeSuggestions(
                  suggestions: suggestions,
                  onSuggestionSelected: (suggestion) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Criar nova tarefa para ${suggestion.start.day}/${suggestion.start.month} às ${suggestion.start.hour.toString().padLeft(2, '0')}:${suggestion.start.minute.toString().padLeft(2, '0')}?',
                        ),
                        backgroundColor: Colors.green,
                        action: SnackBarAction(
                          label: 'Criar',
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pushNamed('/task_form');
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
