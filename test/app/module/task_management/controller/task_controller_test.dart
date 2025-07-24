import 'package:desafio_skillfy/app/module/task_management/controller/task_controller.dart';
import 'package:desafio_skillfy/app/module/task_management/models/enums.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_suggestion.dart';
import 'package:desafio_skillfy/app/module/task_management/models/user_preferences.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/i_suggestions_time.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/i_task_management.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockTaskManagement extends Mock implements ITaskManagement {}

class MockSuggestionsTime extends Mock implements ISuggestionsTime {}

void main() {
  late TaskController controller;
  late MockTaskManagement mockTaskManagement;
  late MockSuggestionsTime mockSuggestionsTime;

  setUp(() {
    mockTaskManagement = MockTaskManagement();
    mockSuggestionsTime = MockSuggestionsTime();
    controller = TaskController(mockTaskManagement, mockSuggestionsTime);
  });

  group('TaskController', () {
    test(
      'loadTasks deve atualizar o estado para sucesso e popular as tarefas em caso de sucesso',
      () async {
        final tasks = [
          Task(
            id: '1',
            title: 'Tarefa de Teste 1',
            priority: TaskPriority.medium,
            category: 'Trabalho',
            estimatedDuration: 60,
            deadline: DateTime.now(),
          ),
        ];
        when(mockTaskManagement.getTasks()).thenAnswer((_) async => tasks);

        await controller.loadTasks();

        expect(controller.state, TaskControllerState.success);
        expect(controller.tasks, tasks);
        verify(mockTaskManagement.getTasks()).called(1);
      },
    );

    test(
      'loadTasks deve atualizar o estado para erro em caso de falha',
      () async {
        when(
          mockTaskManagement.getTasks(),
        ).thenThrow(Exception('Falha ao carregar tarefas'));

        await controller.loadTasks();

        expect(controller.state, TaskControllerState.error);
        expect(controller.errorMessage, contains('Falha ao carregar tarefas'));
        expect(controller.tasks, isEmpty);
        verify(mockTaskManagement.getTasks()).called(1);
      },
    );

    test('loadSuggestions deve popular sugestões em caso de sucesso', () async {
      final suggestions = [
        TaskSuggestion(id: 's1', taskId: 't1', suggestedTimes: []),
      ];
      when(
        mockSuggestionsTime.getSuggestions(),
      ).thenAnswer((_) async => suggestions);

      await controller.loadSuggestions();

      expect(controller.suggestions, suggestions);
      verify(mockSuggestionsTime.getSuggestions()).called(1);
    });

    test(
      'loadSuggestions não deve modificar sugestões em caso de falha',
      () async {
        when(
          mockSuggestionsTime.getSuggestions(),
        ).thenThrow(Exception('Falha ao carregar sugestões'));

        await controller.loadSuggestions();

        expect(
          controller.suggestions,
          isEmpty,
        ); // Deve permanecer vazio se inicial
        verify(mockSuggestionsTime.getSuggestions()).called(1);
      },
    );

    test('setSearchQuery deve filtrar tarefas pelo título', () async {
      final task1 = Task(
        id: '1',
        title: 'Comprar mantimentos',
        priority: TaskPriority.medium,
        category: 'Pessoal',
        estimatedDuration: 60,
        deadline: DateTime.now(),
      );
      final task2 = Task(
        id: '2',
        title: 'Preparar apresentação',
        priority: TaskPriority.high,
        category: 'Trabalho',
        estimatedDuration: 120,
        deadline: DateTime.now(),
      );
      controller.allTasks.addAll([task1, task2]);

      controller.setSearchQuery('mantimentos');
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.title, 'Comprar mantimentos');

      controller.setSearchQuery('apresentação');
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.title, 'Preparar apresentação');

      controller.setSearchQuery('inexistente');
      expect(controller.tasks, isEmpty);
    });

    test('setStatusFilter deve filtrar tarefas pelo status', () async {
      final task1 = Task(
        id: '1',
        title: 'Tarefa A',
        priority: TaskPriority.medium,
        category: 'Trabalho',
        estimatedDuration: 60,
        deadline: DateTime.now(),
        status: TaskStatus.pending,
      );
      final task2 = Task(
        id: '2',
        title: 'Tarefa B',
        priority: TaskPriority.high,
        category: 'Pessoal',
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

    test('clearFilters deve remover todos os filtros', () async {
      final task1 = Task(
        id: '1',
        title: 'Tarefa A',
        priority: TaskPriority.high,
        category: 'Trabalho',
        estimatedDuration: 60,
        deadline: DateTime.now(),
        status: TaskStatus.pending,
      );
      final task2 = Task(
        id: '2',
        title: 'Tarefa B',
        priority: TaskPriority.low,
        category: 'Pessoal',
        estimatedDuration: 120,
        deadline: DateTime.now(),
        status: TaskStatus.completed,
      );
      controller.allTasks.addAll([task1, task2]);

      controller.setSearchQuery('Tarefa');
      controller.setStatusFilter(TaskStatus.pending);
      controller.setPriorityFilter(TaskPriority.high);
      controller.setCategoryFilter('Trabalho');

      expect(controller.tasks.length, 1);

      controller.clearFilters();
      expect(
        controller.tasks.length,
        2,
      ); // Ambas as tarefas devem estar visíveis
      expect(controller.searchQuery, '');
      expect(controller.statusFilter, isNull);
      expect(controller.priorityFilter, isNull);
      expect(controller.categoryFilter, isNull);
    });

    test(
      'weeklyProductivity deve calcular corretamente as tarefas concluídas por dia da semana',
      () {
        final now = DateTime.now();
        final monday = DateTime(now.year, now.month, now.day).subtract(
          Duration(days: now.weekday - 1),
        ); // Segunda-feira da semana atual às 00:00:00

        controller.allTasks.addAll([
          Task(
            id: '1',
            title: 'Tarefa Seg 1',
            priority: TaskPriority.low,
            category: 'Trabalho',
            estimatedDuration: 30,
            deadline: monday.add(Duration(hours: 1)),
            status: TaskStatus.completed,
            completedAt: monday.add(Duration(hours: 2)),
          ),
          Task(
            id: '2',
            title: 'Tarefa Ter 1',
            priority: TaskPriority.medium,
            category: 'Pessoal',
            estimatedDuration: 60,
            deadline: monday.add(Duration(days: 1, hours: 1)), // Terça-feira
            status: TaskStatus.completed,
            completedAt: monday.add(Duration(days: 1, hours: 2)),
          ),
          Task(
            id: '3',
            title: 'Tarefa Seg 2',
            priority: TaskPriority.high,
            category: 'Trabalho',
            estimatedDuration: 90,
            deadline: monday.add(Duration(hours: 3)),
            status: TaskStatus.completed,
            completedAt: monday.add(Duration(hours: 4)),
          ),
          Task(
            id: '4',
            title: 'Tarefa Não Concluída',
            priority: TaskPriority.medium,
            category: 'Trabalho',
            estimatedDuration: 60,
            deadline: now.add(Duration(days: 1)),
            status: TaskStatus.pending,
          ),
          Task(
            id: '5',
            title: 'Tarefa Semana Passada',
            priority: TaskPriority.low,
            category: 'Pessoal',
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

    test('completionRate deve retornar a porcentagem correta', () {
      controller.allTasks.addAll([
        Task(
          id: '1',
          title: 'Tarefa 1',
          priority: TaskPriority.medium,
          category: 'Trabalho',
          estimatedDuration: 60,
          deadline: DateTime.now(),
          status: TaskStatus.completed,
        ),
        Task(
          id: '2',
          title: 'Tarefa 2',
          priority: TaskPriority.medium,
          category: 'Trabalho',
          estimatedDuration: 60,
          deadline: DateTime.now(),
          status: TaskStatus.pending,
        ),
        Task(
          id: '3',
          title: 'Tarefa 3',
          priority: TaskPriority.medium,
          category: 'Trabalho',
          estimatedDuration: 60,
          deadline: DateTime.now(),
          status: TaskStatus.cancelled,
        ),
      ]);

      expect(controller.completionRate, closeTo(33.33, 0.01));

      controller.allTasks.clear();
      expect(controller.completionRate, 0.0);
    });

    test(
      'overdueTasks deve retornar tarefas com prazo no passado e não concluídas',
      () {
        final now = DateTime.now();
        controller.allTasks.addAll([
          Task(
            id: '1',
            title: 'Tarefa Atrasada 1',
            priority: TaskPriority.high,
            category: 'Trabalho',
            estimatedDuration: 60,
            deadline: now.subtract(Duration(days: 1)),
            status: TaskStatus.pending,
          ),
          Task(
            id: '2',
            title: 'Tarefa Atrasada 2 (em progresso)',
            priority: TaskPriority.medium,
            category: 'Pessoal',
            estimatedDuration: 30,
            deadline: now.subtract(Duration(hours: 1)),
            status: TaskStatus.inProgress,
          ),
          Task(
            id: '3',
            title: 'Tarefa Concluída',
            priority: TaskPriority.low,
            category: 'Trabalho',
            estimatedDuration: 90,
            deadline: now.subtract(Duration(days: 2)),
            status: TaskStatus.completed,
          ),
          Task(
            id: '4',
            title: 'Tarefa Futura',
            priority: TaskPriority.high,
            category: 'Pessoal',
            estimatedDuration: 45,
            deadline: now.add(Duration(days: 1)),
            status: TaskStatus.pending,
          ),
          Task(
            id: '5',
            title: 'Tarefa Cancelada',
            priority: TaskPriority.high,
            category: 'Pessoal',
            estimatedDuration: 45,
            deadline: now.subtract(Duration(days: 1)),
            status: TaskStatus.cancelled,
          ),
        ]);

        final overdue = controller.overdueTasks;
        expect(overdue.length, 2);
        expect(overdue.any((task) => task.id == '1'), isTrue);
        expect(overdue.any((task) => task.id == '2'), isTrue);
        expect(overdue.any((task) => task.id == '3'), isFalse);
        expect(overdue.any((task) => task.id == '4'), isFalse);
        expect(overdue.any((task) => task.id == '5'), isFalse);
      },
    );

    test('updateUserPreferences deve atualizar as preferências do usuário', () {
      final newPreferences = UserPreferences(
        workingHours: WorkingHours(start: '10:00', end: '19:00'),
        preferredCategories: ['estudo', 'hobby'],
      );

      controller.updateUserPreferences(newPreferences);

      expect(controller.userPreferences.workingHours.start, '10:00');
      expect(controller.userPreferences.preferredCategories, [
        'estudo',
        'hobby',
      ]);
    });
  });
}
