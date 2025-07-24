import 'package:desafio_skillfy/app/core/constants/routes_api.dart';
import 'package:desafio_skillfy/app/core/service/client/i_http_client.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/i_task_management.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/task_management_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class MockHttpClientManual implements IHttpClient {
  Future<HttpResponse> Function()? onGet;
  Future<HttpResponse> Function()? onPost;
  Future<HttpResponse> Function()? onPut;
  Future<HttpResponse> Function()? onDelete;

  String? lastPath;
  dynamic lastData;

  @override
  Future<HttpResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    lastPath = path;
    if (onGet != null) {
      return onGet!();
    }
    throw Exception('Handler "onGet" não foi definido para o teste.');
  }

  @override
  Future<HttpResponse> post(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    lastPath = path;
    lastData = data;
    if (onPost != null) {
      return onPost!();
    }
    throw Exception('Handler "onPost" não foi definido para o teste.');
  }

  @override
  Future<HttpResponse> put(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    lastPath = path;
    lastData = data;
    if (onPut != null) {
      return onPut!();
    }
    throw Exception('Handler "onPut" não foi definido para o teste.');
  }

  @override
  Future<HttpResponse> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    lastPath = path;
    if (onDelete != null) {
      return onDelete!();
    }
    throw Exception('Handler "onDelete" não foi definido para o teste.');
  }
}

void main() {
  late MockHttpClientManual mockHttpClient;
  late ITaskManagement taskManagement;

  setUp(() {
    mockHttpClient = MockHttpClientManual();
    taskManagement = TaskManagementImpl(mockHttpClient);
  });

  final taskJson = {
    'id': '193829c6-b91d-402d-82d6-127a546e3514',
    'title': 'teste 2',
    'description': '',
    'priority': 'medium',
    'category': 'personal',
    'estimated_duration': 60,
    'deadline': '2025-07-25T09:00:00.000Z',
    'status': 'completed',
    'completed_at': '2025-07-24T16:32:10.714953',
  };

  final task = Task.fromJson(taskJson);
  final tasksListJson = [taskJson];

  group('TaskManagementImpl Tests', () {
    group('getTasks', () {
      test('deve retornar uma lista de tarefas em caso de sucesso', () async {
        mockHttpClient.onGet = () async => HttpResponse.success(tasksListJson);

        final result = await taskManagement.getTasks();

        expect(result, isA<List<Task>>());
        expect(result.first.id, task.id);
        expect(mockHttpClient.lastPath, RoutesApi.tasks);
      });

      test('deve lançar uma exceção quando a requisição falhar', () async {
        mockHttpClient.onGet = () async =>
            HttpResponse.error('Erro de servidor');

        expect(
          () async => await taskManagement.getTasks(),
          throwsA(isA<Exception>()),
        );
        expect(mockHttpClient.lastPath, RoutesApi.tasks);
      });
    });

    group('getTaskById', () {
      const taskId = '193829c6-b91d-402d-82d6-127a546e3514';

      test('deve retornar uma tarefa quando o ID existe', () async {
        mockHttpClient.onGet = () async => HttpResponse.success(taskJson);

        final result = await taskManagement.getTaskById(taskId);

        expect(result, isA<Task>());
        expect(result?.id, taskId);
        expect(mockHttpClient.lastPath, '${RoutesApi.tasks}/$taskId');
      });
    });

    group('createTask', () {
      test('deve retornar a tarefa criada em caso de sucesso', () async {
        mockHttpClient.onPost = () async => HttpResponse.success(taskJson);

        final result = await taskManagement.createTask(task);

        expect(result.id, task.id);
        expect(mockHttpClient.lastPath, RoutesApi.tasks);
        expect(mockHttpClient.lastData, task.toJson());
      });
    });

    group('updateTask', () {
      final updatedTask = task.copyWith(title: 'Título Atualizado');

      test('deve retornar a tarefa atualizada em caso de sucesso', () async {
        mockHttpClient.onPut = () async =>
            HttpResponse.success(updatedTask.toJson());

        final result = await taskManagement.updateTask(updatedTask);

        expect(result.title, 'Título Atualizado');
        expect(mockHttpClient.lastPath, '${RoutesApi.tasks}/${updatedTask.id}');
        expect(mockHttpClient.lastData, updatedTask.toJson());
      });
    });

    group('deleteTask', () {
      const taskIdToDelete = 'some-task-id';

      test('deve completar sem erros em caso de sucesso na deleção', () async {
        mockHttpClient.onDelete = () async =>
            HttpResponse.success(null, statusCode: 204);

        await expectLater(taskManagement.deleteTask(taskIdToDelete), completes);
        expect(mockHttpClient.lastPath, '${RoutesApi.tasks}/$taskIdToDelete');
      });
    });
  });
}
