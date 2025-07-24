import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_suggestion.dart';
import 'package:desafio_skillfy/app/module/task_management/models/user_preferences.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/i_suggestions_time.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/i_task_management.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum TaskControllerState { idle, loading, success, error }

class TaskController extends ChangeNotifier {
  final ITaskManagement _repository;
  final ISuggestionsTime _suggestionsRepository;

  TaskController(this._repository, this._suggestionsRepository);

  TaskControllerState _state = TaskControllerState.idle;
  String? _errorMessage;

  List<Task> _tasks = [];
  List<TaskSuggestion> _suggestions = [];
  UserPreferences _userPreferences = UserPreferences(
    workingHours: WorkingHours(start: '09:00', end: '18:00'),
  );

  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  String? _categoryFilter;
  String _searchQuery = '';

  TaskControllerState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Task> get tasks => _getFilteredTasks();
  List<Task> get allTasks => _tasks;
  List<TaskSuggestion> get suggestions => _suggestions;
  UserPreferences get userPreferences => _userPreferences;

  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;
  String? get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;

  int get totalTasks => _tasks.length;
  int get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.completed).length;
  int get pendingTasks =>
      _tasks.where((t) => t.status == TaskStatus.pending).length;
  int get inProgressTasks =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get cancelledTasks =>
      _tasks.where((t) => t.status == TaskStatus.cancelled).length;

  List<String> get categories => _tasks.map((t) => t.category).toSet().toList();

  Map<String, int> get weeklyProductivity {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyData = <String, int>{};

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayName = _getDayName(day.weekday);
      weeklyData[dayName] = 0;
    }

    final completedTasks = _tasks.where(
      (task) => task.status == TaskStatus.completed && task.completedAt != null,
    );

    for (final task in completedTasks) {
      final completedDate = task.completedAt!;
      final dayOfWeek = completedDate.weekday;
      final dayName = _getDayName(dayOfWeek);

      if (completedDate.isAfter(weekStart.subtract(Duration(days: 1))) &&
          completedDate.isBefore(weekStart.add(Duration(days: 7)))) {
        weeklyData[dayName] = (weeklyData[dayName] ?? 0) + 1;
      }
    }

    return weeklyData;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Seg';
      case 2:
        return 'Ter';
      case 3:
        return 'Qua';
      case 4:
        return 'Qui';
      case 5:
        return 'Sex';
      case 6:
        return 'Sáb';
      case 7:
        return 'Dom';
      default:
        return '';
    }
  }

  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return (completedTasks / totalTasks) * 100;
  }

  List<Task> get overdueTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      return task.status != TaskStatus.completed && task.deadline.isBefore(now);
    }).toList();
  }

  void _setState(TaskControllerState newState, [String? error]) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  List<Task> _getFilteredTasks() {
    var filtered = _tasks.where((task) {
      if (_statusFilter != null && task.status != _statusFilter) {
        return false;
      }

      if (_priorityFilter != null && task.priority != _priorityFilter) {
        return false;
      }

      if (_categoryFilter != null &&
          _categoryFilter!.isNotEmpty &&
          task.category != _categoryFilter) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      final aPriority = priorityOrder[a.priority.name] ?? 999;
      final bPriority = priorityOrder[b.priority.name] ?? 999;

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      return a.deadline.compareTo(b.deadline);
    });

    return filtered;
  }

  Future<void> loadTasks() async {
    _setState(TaskControllerState.loading);

    try {
      _tasks = await _repository.getTasks();
      _setState(TaskControllerState.success);
    } catch (e) {
      _setState(TaskControllerState.error, e.toString());
    }
  }

  Future<void> loadSuggestions() async {
    try {
      _suggestions = await _suggestionsRepository.getSuggestions();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar sugestões: $e');
    }
  }

  Future<void> createTask(Task task) async {
    final taskWithId = task.id == null
        ? task.copyWith(id: const Uuid().v4())
        : task;

    _tasks.add(taskWithId);
    _setState(TaskControllerState.success);

    try {
      await _repository.createTask(taskWithId);
    } catch (e) {
      _tasks.removeWhere((t) => t.id == taskWithId.id);
      _setState(
        TaskControllerState.error,
        "Falha ao salvar a tarefa: ${e.toString()}",
      );
    }
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      _setState(
        TaskControllerState.error,
        "Tentativa de atualizar uma tarefa com ID nulo.",
      );
      return;
    }

    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      _setState(
        TaskControllerState.error,
        "Tarefa com ID ${task.id} não encontrada para atualização.",
      );
      return;
    }

    final originalTask = _tasks[index];

    _tasks = List.from(_tasks);
    _tasks[index] = task;
    notifyListeners();

    try {
      final updatedTaskFromServer = await _repository.updateTask(task);

      _tasks = List.from(_tasks);
      _tasks[index] = updatedTaskFromServer;
      _setState(TaskControllerState.success);
    } catch (e) {
      _tasks = List.from(_tasks);
      _tasks[index] = originalTask;
      _setState(
        TaskControllerState.error,
        "Falha ao atualizar a tarefa: ${e.toString()}",
      );
    }
  }

  Future<void> deleteTask(String id) async {
    _setState(TaskControllerState.loading);

    try {
      await _repository.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      _suggestions.removeWhere((suggestion) => suggestion.taskId == id);
      _setState(TaskControllerState.success);
    } catch (e) {
      _setState(TaskControllerState.error, e.toString());
    }
  }

  Future<void> markTaskAsCompleted(Task task) async {
    if (task.id == null) {
      debugPrint(
        "Não é possível marcar como concluída uma tarefa com ID nulo.",
      );
      return;
    }

    if (task.status != TaskStatus.completed &&
        task.status != TaskStatus.cancelled) {
      final updatedTask = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
      await updateTask(updatedTask);
    }
  }

  Future<void> toggleTaskStatus(Task task) async {
    if (task.id == null) return;

    TaskStatus newStatus;
    switch (task.status) {
      case TaskStatus.pending:
        newStatus = TaskStatus.inProgress;
        break;
      case TaskStatus.inProgress:
        newStatus = TaskStatus.completed;
        break;
      case TaskStatus.completed:
        return;
      case TaskStatus.cancelled:
        return;
    }

    final updatedTask = task.copyWith(status: newStatus);
    await updateTask(updatedTask);
  }

  Future<void> markTaskAsCancelled(Task task) async {
    if (task.id == null || task.status == TaskStatus.completed) return;

    final updatedTask = task.copyWith(status: TaskStatus.cancelled);
    await updateTask(updatedTask);
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<TaskSuggestion?> requestTimeSuggestion(Task task) async {
    try {
      final request = SuggestTimeRequest(
        task: task,
        userPreferences: _userPreferences,
      );

      final suggestion = await _suggestionsRepository.requestTimeSuggestion(
        request,
      );

      final existingIndex = _suggestions.indexWhere((s) => s.taskId == task.id);
      if (existingIndex != -1) {
        _suggestions[existingIndex] = suggestion;
      } else {
        _suggestions.add(suggestion);
      }

      notifyListeners();
      return suggestion;
    } catch (e) {
      debugPrint('Erro ao solicitar sugestão: $e');
      return null;
    }
  }

  TaskSuggestion? getSuggestionForTask(String taskId) {
    try {
      return _suggestions.firstWhere((s) => s.taskId == taskId);
    } catch (e) {
      return null;
    }
  }

  List<SuggestedTime> get genericTimeSuggestions {
    return _suggestions
        .expand((taskSuggestion) => taskSuggestion.suggestedTimes)
        .toList();
  }

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    _categoryFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  void updateUserPreferences(UserPreferences preferences) {
    _userPreferences = preferences;
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([loadTasks(), loadSuggestions()]);
  }
}
