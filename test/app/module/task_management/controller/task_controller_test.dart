import 'package:desafio_skillfy/app/module/task_management/controller/task_controller.dart';
import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_suggestion.dart';
import 'package:desafio_skillfy/app/module/task_management/models/user_preferences.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/i_suggestions_time.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/i_task_management.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'task_controller_test.mocks.dart';

@GenerateMocks([ITaskManagement, ISuggestionsTime])
void main() {
  late TaskController controller;
  late MockITaskManagement mockTaskManagement;
  late MockISuggestionsTime mockSuggestionsTime;

  setUp(() {
    mockTaskManagement = MockITaskManagement();
    mockSuggestionsTime = MockISuggestionsTime();
    controller = TaskController(mockTaskManagement, mockSuggestionsTime);
  });

  group('Testes do TaskController', () {
    test('loadTasks atualiza estado para sucesso e popula tarefas', () async {
      final tasks = [
        Task(
          id: '1',
          title: 'Test Task 1',
          priority: TaskPriority.medium,
          category: 'Work',
          estimatedDuration: 60,
          deadline: DateTime.now(),
        ),
      ];
      when(
        mockTaskManagement.getTasks(),
      ).thenAnswer((_) => Future.value(tasks));

      await controller.loadTasks();

      expect(controller.state, TaskControllerState.success);
      expect(controller.tasks, tasks);
      verify(mockTaskManagement.getTasks()).called(1);
      verifyNoMoreInteractions(mockTaskManagement);
    });

    test('loadTasks atualiza estado para erro em caso de falha', () async {
      when(
        mockTaskManagement.getTasks(),
      ).thenAnswer((_) => Future.error(Exception('Falha ao carregar tarefas')));

      await controller.loadTasks();

      expect(controller.state, TaskControllerState.error);
      expect(controller.errorMessage, contains('Falha ao carregar tarefas'));
      expect(controller.tasks, isEmpty);
      verify(mockTaskManagement.getTasks()).called(1);
      verifyNoMoreInteractions(mockTaskManagement);
    });

    test('loadSuggestions popula sugestões em caso de sucesso', () async {
      final suggestions = [
        TaskSuggestion(id: 's1', taskId: 't1', suggestedTimes: []),
      ];
      when(
        mockSuggestionsTime.getSuggestions(),
      ).thenAnswer((_) => Future.value(suggestions));

      await controller.loadSuggestions();

      expect(controller.suggestions, suggestions);
      verify(mockSuggestionsTime.getSuggestions()).called(1);
      verifyNoMoreInteractions(mockSuggestionsTime);
    });

    test('loadSuggestions não modifica sugestões em caso de falha', () async {
      when(mockSuggestionsTime.getSuggestions()).thenAnswer(
        (_) => Future.error(Exception('Falha ao carregar sugestões')),
      );

      await controller.loadSuggestions();

      expect(controller.suggestions, isEmpty);
      verify(mockSuggestionsTime.getSuggestions()).called(1);
      verifyNoMoreInteractions(mockSuggestionsTime);
    });

    test('setSearchQuery filtra tarefas pelo título', () async {
      final task1 = Task(
        id: '1',
        title: 'Buy groceries',
        priority: TaskPriority.medium,
        category: 'Personal',
        estimatedDuration: 60,
        deadline: DateTime.now(),
      );
      final task2 = Task(
        id: '2',
        title: 'Prepare presentation',
        priority: TaskPriority.high,
        category: 'Work',
        estimatedDuration: 120,
        deadline: DateTime.now(),
      );
      controller.allTasks.addAll([task1, task2]);

      controller.setSearchQuery('groceries');
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.title, 'Buy groceries');

      controller.setSearchQuery('presentation');
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.title, 'Prepare presentation');

      controller.setSearchQuery('nonexistent');
      expect(controller.tasks, isEmpty);
    });

    test('setStatusFilter filtra tarefas pelo status', () async {
      final task1 = Task(
        id: '1',
        title: 'Task A',
        priority: TaskPriority.medium,
        category: 'Work',
        estimatedDuration: 60,
        deadline: DateTime.now(),
        status: TaskStatus.pending,
      );
      final task2 = Task(
        id: '2',
        title: 'Task B',
        priority: TaskPriority.high,
        category: 'Personal',
        estimatedDuration: 120,
        deadline: DateTime.now(),
        status: TaskStatus.completed,
      );
      controller.allTasks.addAll([task1, task2]);

      controller.setStatusFilter(TaskStatus.pending);
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.status, TaskStatus.pending);

      controller.setStatusFilter(TaskStatus.completed);
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.status, TaskStatus.completed);

      controller.setStatusFilter(TaskStatus.inProgress);
      expect(controller.tasks, isEmpty);
    });

    test('clearFilters remove todos os filtros', () async {
      final task1 = Task(
        id: '1',
        title: 'Task A',
        priority: TaskPriority.high,
        category: 'Work',
        estimatedDuration: 60,
        deadline: DateTime.now(),
        status: TaskStatus.pending,
      );
      final task2 = Task(
        id: '2',
        title: 'Task B',
        priority: TaskPriority.low,
        category: 'Personal',
        estimatedDuration: 120,
        deadline: DateTime.now(),
        status: TaskStatus.completed,
      );
      controller.allTasks.addAll([task1, task2]);

      controller.setSearchQuery('Task');
      controller.setStatusFilter(TaskStatus.pending);
      controller.setPriorityFilter(TaskPriority.high);
      controller.setCategoryFilter('Work');

      expect(controller.tasks.length, 1);

      controller.clearFilters();
      expect(controller.tasks.length, 2);
      expect(controller.searchQuery, '');
      expect(controller.statusFilter, isNull);
      expect(controller.priorityFilter, isNull);
      expect(controller.categoryFilter, isNull);
    });

    test(
      'weeklyProductivity calcula tarefas concluídas por dia corretamente',
      () {
        final now = DateTime.now();
        final monday = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));

        controller.allTasks.addAll([
          Task(
            id: '1',
            title: 'Task Mon 1',
            priority: TaskPriority.low,
            category: 'Work',
            estimatedDuration: 30,
            deadline: monday.add(Duration(hours: 1)),
            status: TaskStatus.completed,
            completedAt: monday.add(Duration(hours: 2)),
          ),
          Task(
            id: '2',
            title: 'Task Tue 1',
            priority: TaskPriority.medium,
            category: 'Personal',
            estimatedDuration: 60,
            deadline: monday.add(Duration(days: 1, hours: 1)),
            status: TaskStatus.completed,
            completedAt: monday.add(Duration(days: 1, hours: 2)),
          ),
          Task(
            id: '3',
            title: 'Task Mon 2',
            priority: TaskPriority.high,
            category: 'Work',
            estimatedDuration: 90,
            deadline: monday.add(Duration(hours: 3)),
            status: TaskStatus.completed,
            completedAt: monday.add(Duration(hours: 4)),
          ),
          Task(
            id: '4',
            title: 'Task Not Completed',
            priority: TaskPriority.medium,
            category: 'Work',
            estimatedDuration: 60,
            deadline: now.add(Duration(days: 1)),
            status: TaskStatus.pending,
          ),
          Task(
            id: '5',
            title: 'Task Last Week',
            priority: TaskPriority.low,
            category: 'Personal',
            estimatedDuration: 30,
            deadline: monday
                .subtract(Duration(days: 7))
                .add(Duration(hours: 1)),
            status: TaskStatus.completed,
            completedAt: monday
                .subtract(Duration(days: 7))
                .add(Duration(hours: 2)),
          ),
        ]);

        final weeklyProd = controller.weeklyProductivity;

        expect(weeklyProd['Seg'], 2);
        expect(weeklyProd['Ter'], 1);
        expect(weeklyProd['Qua'], 0);
        expect(weeklyProd['Qui'], 0);
        expect(weeklyProd['Sex'], 0);
        expect(weeklyProd['Sáb'], 0);
        expect(weeklyProd['Dom'], 0);
      },
    );

    test('completionRate retorna porcentagem correta', () {
      controller.allTasks.addAll([
        Task(
          id: '1',
          title: 'Task 1',
          priority: TaskPriority.medium,
          category: 'Work',
          estimatedDuration: 60,
          deadline: DateTime.now(),
          status: TaskStatus.completed,
        ),
        Task(
          id: '2',
          title: 'Task 2',
          priority: TaskPriority.medium,
          category: 'Work',
          estimatedDuration: 60,
          deadline: DateTime.now(),
          status: TaskStatus.pending,
        ),
        Task(
          id: '3',
          title: 'Task 3',
          priority: TaskPriority.medium,
          category: 'Work',
          estimatedDuration: 60,
          deadline: DateTime.now(),
          status: TaskStatus.cancelled,
        ),
      ]);

      expect(controller.completionRate, closeTo(33.33, 0.01));

      controller.allTasks.clear();
      expect(controller.completionRate, 0.0);
    });

    test('overdueTasks retorna tarefas não concluídas após o prazo', () {
      final now = DateTime.now();
      controller.allTasks.addAll([
        Task(
          id: '1',
          title: 'Overdue Task 1',
          priority: TaskPriority.high,
          category: 'Work',
          estimatedDuration: 60,
          deadline: now.subtract(Duration(days: 1)),
          status: TaskStatus.pending,
        ),
        Task(
          id: '2',
          title: 'Overdue Task 2 (In Progress)',
          priority: TaskPriority.medium,
          category: 'Personal',
          estimatedDuration: 30,
          deadline: now.subtract(Duration(hours: 1)),
          status: TaskStatus.inProgress,
        ),
        Task(
          id: '3',
          title: 'Completed Task',
          priority: TaskPriority.low,
          category: 'Work',
          estimatedDuration: 90,
          deadline: now.subtract(Duration(days: 2)),
          status: TaskStatus.completed,
        ),
        Task(
          id: '4',
          title: 'Future Task',
          priority: TaskPriority.high,
          category: 'Personal',
          estimatedDuration: 45,
          deadline: now.add(Duration(days: 1)),
          status: TaskStatus.pending,
        ),
        Task(
          id: '5',
          title: 'Cancelled Task',
          priority: TaskPriority.high,
          category: 'Personal',
          estimatedDuration: 45,
          deadline: now.subtract(Duration(days: 1)),
          status: TaskStatus.cancelled,
        ),
      ]);

      final overdue = controller.overdueTasks;
      expect(overdue.length, 3);
      expect(overdue.any((task) => task.id == '1'), isTrue);
      expect(overdue.any((task) => task.id == '2'), isTrue);
      expect(overdue.any((task) => task.id == '3'), isFalse);
      expect(overdue.any((task) => task.id == '4'), isFalse);
      expect(overdue.any((task) => task.id == '5'), isTrue);
    });

    test(
      'updateUserPreferences atualiza preferências do usuário corretamente',
      () {
        final newPreferences = UserPreferences(
          workingHours: WorkingHours(start: '10:00', end: '19:00'),
          preferredCategories: ['study', 'hobby'],
        );

        controller.updateUserPreferences(newPreferences);

        expect(controller.userPreferences.workingHours.start, '10:00');
        expect(controller.userPreferences.workingHours.end, '19:00');
        expect(controller.userPreferences.preferredCategories, [
          'study',
          'hobby',
        ]);
      },
    );

    test(
      'createTask adiciona tarefa e atualiza estado em caso de sucesso',
      () async {
        final task = Task(
          id: null,
          title: 'New Task',
          priority: TaskPriority.medium,
          category: 'Work',
          estimatedDuration: 60,
          deadline: DateTime.now(),
        );
        final taskWithId = task.copyWith(id: '1');
        when(
          mockTaskManagement.createTask(any),
        ).thenAnswer((_) => Future.value(taskWithId));

        await controller.createTask(task);

        expect(controller.state, TaskControllerState.success);
        expect(controller.tasks.length, 1);
        expect(controller.tasks.first.title, 'New Task');
        expect(controller.tasks.first.id, isNotNull);
        verify(mockTaskManagement.createTask(any)).called(1);
        verifyNoMoreInteractions(mockTaskManagement);
      },
    );

    test('updateTask atualiza tarefa e estado em caso de sucesso', () async {
      final task = Task(
        id: '1',
        title: 'Task 1',
        priority: TaskPriority.medium,
        category: 'Work',
        estimatedDuration: 60,
        deadline: DateTime.now(),
      );
      controller.allTasks.add(task);
      final updatedTask = task.copyWith(title: 'Updated Task');

      when(
        mockTaskManagement.updateTask(any),
      ).thenAnswer((_) => Future.value(updatedTask));

      await controller.updateTask(updatedTask);

      expect(controller.state, TaskControllerState.success);
      expect(controller.tasks.first.title, 'Updated Task');
      verify(mockTaskManagement.updateTask(any)).called(1);
      verifyNoMoreInteractions(mockTaskManagement);
    });
  });
}
