import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:desafio_skillfy/app/module/task_management/controller/task_controller.dart';
import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_suggestion.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/category_chip.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/priority_badge.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/task_card.dart';
import 'package:desafio_skillfy/app/module/task_management/ui/widgets/time_suggestions.dart';
import 'package:uuid/uuid.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? taskToEdit;

  const TaskFormScreen({super.key, this.taskToEdit});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;

  bool get isEditing => widget.taskToEdit != null;
  bool get canBeModified => widget.taskToEdit?.id != null;

  String? _selectedCategory;
  TaskPriority? _selectedPriority;
  DateTime? _selectedDeadline;
  TaskStatus? _selectedStatus;

  List<SuggestedTime> _timeSuggestions = [];
  bool _isSuggestingTime = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _durationController = TextEditingController(
      text: task?.estimatedDuration.toString() ?? '',
    );
    _selectedCategory = task?.category;
    _selectedPriority = task?.priority;
    _selectedDeadline = task?.deadline;
    _selectedStatus = task?.status;

    // NOVO: Carrega sugestões genéricas ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<TaskController>();

      // Carrega sugestões específicas se estiver editando
      if (task?.id != null) {
        final existingSuggestion = controller.getSuggestionForTask(task!.id!);
        if (existingSuggestion != null) {
          setState(() {
            _timeSuggestions = existingSuggestion.suggestedTimes;
          });
        }
      }

      // NOVO: Sempre carrega as sugestões genéricas disponíveis
      if (_timeSuggestions.isEmpty) {
        setState(() {
          _timeSuggestions = controller.genericTimeSuggestions;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedPriority == null ||
        _selectedCategory == null ||
        _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, preencha todos os campos obrigatórios (*).',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final controller = context.read<TaskController>();

    // CORRIGIDO: Garante que toda tarefa tenha um ID válido
    final taskId = widget.taskToEdit?.id ?? const Uuid().v4();

    final taskToSave = Task(
      id: taskId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _selectedPriority!,
      category: _selectedCategory!,
      estimatedDuration: int.parse(_durationController.text),
      deadline: _selectedDeadline!,
      status: _selectedStatus ?? TaskStatus.pending,
      // NOVO: Define completedAt se o status for completed
      completedAt: (_selectedStatus == TaskStatus.completed)
          ? DateTime.now()
          : widget.taskToEdit?.completedAt,
    );

    try {
      if (widget.taskToEdit == null) {
        await controller.createTask(taskToSave);
      } else {
        await controller.updateTask(taskToSave);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !isEditing
                ? 'Tarefa criada com sucesso!'
                : 'Tarefa atualizada com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar tarefa: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTask() async {
    if (widget.taskToEdit == null || !canBeModified) return;

    final confirmed = await showDialog<bool>(
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
            'Tem certeza que deseja excluir esta tarefa? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = context.read<TaskController>();
      await controller.deleteTask(widget.taskToEdit!.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarefa excluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir tarefa: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchTimeSuggestions() async {
    if (_titleController.text.trim().isEmpty ||
        _durationController.text.isEmpty ||
        _selectedPriority == null ||
        _selectedCategory == null ||
        _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os campos obrigatórios para obter sugestões.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSuggestingTime = true;
    });

    final controller = context.read<TaskController>();
    final taskData = Task(
      id: widget.taskToEdit?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _selectedPriority!,
      category: _selectedCategory!,
      estimatedDuration: int.parse(_durationController.text),
      deadline: _selectedDeadline!,
      status: _selectedStatus ?? TaskStatus.pending,
    );

    try {
      final suggestion = await controller.requestTimeSuggestion(taskData);
      setState(() {
        if (suggestion != null) {
          _timeSuggestions = suggestion.suggestedTimes;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar sugestões: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSuggestingTime = false;
        });
      }
    }
  }

  void _presentDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDeadline ?? DateTime.now(),
        ),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;
    final previewTask = Task(
      id: widget.taskToEdit?.id,
      title: _titleController.text.isNotEmpty
          ? _titleController.text
          : 'Título da Tarefa',
      description: _descriptionController.text,
      priority: _selectedPriority ?? TaskPriority.medium,
      estimatedDuration: int.tryParse(_durationController.text) ?? 60,
      deadline:
          _selectedDeadline ?? DateTime.now().add(const Duration(hours: 1)),
      category: _selectedCategory ?? 'work',
      status: _selectedStatus ?? TaskStatus.pending,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
        actions: [
          if (isEditing && canBeModified)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteTask,
              tooltip: 'Excluir Tarefa',
              color: Colors.red,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: (_isLoading || (isEditing && !canBeModified))
                ? null
                : _saveTask,
            tooltip: 'Salvar Tarefa',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira um título.';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (Opcional)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategorySelection(),
                  const SizedBox(height: 16),
                  _buildPrioritySelection(),
                  const SizedBox(height: 16),
                  if (isEditing) ...[
                    _buildStatusSelection(),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duração Estimada (minutos)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a duração.';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Por favor, insira um número válido.';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDeadlinePicker(context),
                  const SizedBox(height: 24),
                  _buildTimeSuggestionsSection(),
                  const SizedBox(height: 24),
                  _buildPreviewSection(previewTask),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues( alpha:0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    final categories = context
        .read<TaskController>()
        .userPreferences
        .preferredCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: categories.map((category) {
            return CategoryChip(
              category: category,
              isSelected: _selectedCategory == category,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
            );
          }).toList(),
        ),
        if (_selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Selecione uma categoria',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildPrioritySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prioridade',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TaskPriority>(
          value: _selectedPriority,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            prefixIcon: Icon(Icons.flag),
          ),
          hint: const Text('Selecione a Prioridade'),
          onChanged: (TaskPriority? newValue) {
            setState(() {
              _selectedPriority = newValue;
            });
          },
          items: TaskPriority.values.map((priority) {
            return DropdownMenuItem(
              value: priority,
              child: PriorityBadge(priority: priority, showLabel: true),
            );
          }).toList(),
          validator: (value) {
            if (value == null) {
              return 'Por favor, selecione uma prioridade.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusSelection() {
    // CORRIGIDO: Impede mudança para completed ou cancelled se já estiver nesses estados
    final availableStatuses = TaskStatus.values.where((status) {
      if (widget.taskToEdit?.status == TaskStatus.completed ||
          widget.taskToEdit?.status == TaskStatus.cancelled) {
        return status == widget.taskToEdit?.status;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<TaskStatus>(
          value: _selectedStatus,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            prefixIcon: Icon(Icons.radio_button_checked),
          ),
          hint: const Text('Selecione o Status'),
          onChanged: (TaskStatus? newValue) {
            setState(() {
              _selectedStatus = newValue;
            });
          },
          items: availableStatuses.map((status) {
            IconData icon;
            Color color;

            switch (status) {
              case TaskStatus.pending:
                icon = Icons.pending;
                color = Colors.orange;
                break;
              case TaskStatus.inProgress:
                icon = Icons.play_circle_outline;
                color = Colors.blue;
                break;
              case TaskStatus.completed:
                icon = Icons.check_circle;
                color = Colors.green;
                break;
              case TaskStatus.cancelled:
                icon = Icons.cancel;
                color = Colors.red;
                break;
            }

            return DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(status.displayName),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeadlinePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prazo Final',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _presentDatePicker,
          child: InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              prefixIcon: const Icon(Icons.calendar_today),
              errorText: _selectedDeadline == null
                  ? 'Selecione uma data'
                  : null,
            ),
            child: Text(
              _selectedDeadline == null
                  ? 'Selecione a Data e Hora'
                  : DateFormat.yMd().add_jm().format(_selectedDeadline!),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sugestões de Horário',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            // _isSuggestingTime
            //     ? const SizedBox(
            //         height: 24,
            //         width: 24,
            //         child: CircularProgressIndicator(strokeWidth: 2),
            //       )
            //     : ElevatedButton.icon(
            //         onPressed: _fetchTimeSuggestions,
            //         icon: const Icon(Icons.lightbulb_outline),
            //         label: const Text('Buscar Sugestões'),
            //       ),
          ],
        ),
        const SizedBox(height: 12),
        // NOVO: Mostra sugestões genéricas como referência
        // if (_timeSuggestions.isNotEmpty) ...[
        //   Container(
        //     padding: const EdgeInsets.all(12),
        //     decoration: BoxDecoration(
        //       color: Theme.of(
        //         context,
        //       ).colorScheme.surfaceContainerHighest.withValues( alpha:0.3),
        //       borderRadius: BorderRadius.circular(8),
        //       border: Border.all(
        //         color: Theme.of(context).colorScheme.outlineVariant,
        //       ),
        //     ),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Row(
        //           children: [
        //             Icon(
        //               Icons.lightbulb_outline,
        //               size: 16,
        //               color: Theme.of(context).colorScheme.primary,
        //             ),
        //             const SizedBox(width: 8),
        //             Text(
        //               'Horários Sugeridos (Referência)',
        //               style: Theme.of(context).textTheme.labelMedium?.copyWith(
        //                 fontWeight: FontWeight.w600,
        //                 color: Theme.of(context).colorScheme.primary,
        //               ),
        //             ),
        //           ],
        //         ),
        //         const SizedBox(height: 8),
        //         Text(
        //           'Use essas sugestões como referência para definir o prazo da sua tarefa:',
        //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
        //             color: Theme.of(context).colorScheme.onSurfaceVariant,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        //   const SizedBox(height: 8),
        // ],
        TimeSuggestions(
          suggestions: _timeSuggestions,
          onSuggestionSelected: (suggestion) {
            setState(() {
              _selectedDeadline = suggestion.start;
              if (suggestion.end != null) {
                final duration = suggestion.end!
                    .difference(suggestion.start)
                    .inMinutes;
                _durationController.text = duration.toString();
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Horário aplicado: ${DateFormat.yMd().add_jm().format(suggestion.start)}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPreviewSection(Task previewTask) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview da Tarefa',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TaskCard(task: previewTask),
      ],
    );
  }
}
