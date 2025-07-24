import 'package:desafio_skillfy/app/core/service/client/i_http_client.dart';
import 'package:desafio_skillfy/app/core/constants/routes_api.dart';
import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';
import 'package:desafio_skillfy/app/module/task_management/repository/i_task_management.dart';

class TaskManagementImpl implements ITaskManagement {
  final IHttpClient _httpClient;

  TaskManagementImpl(this._httpClient);

  @override
  Future<List<Task>> getTasks() async {
    try {
      final response = await _httpClient.get(RoutesApi.tasks);

      if (response.isSuccess) {
        final List<dynamic> tasksJson = response.data as List<dynamic>;
        return tasksJson
            .map((json) => Task.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.message ?? 'Erro ao buscar tarefas');
      }
    } catch (e) {
      throw Exception('Falha ao carregar tarefas: ${e.toString()}');
    }
  }

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      final response = await _httpClient.get('${RoutesApi.tasks}/$id');

      if (response.isSuccess) {
        return Task.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(response.message ?? 'Erro ao buscar tarefa');
      }
    } catch (e) {
      throw Exception('Falha ao carregar tarefa: ${e.toString()}');
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    try {
      final response = await _httpClient.post(
        RoutesApi.tasks,
        data: task.toJson(),
      );

      if (response.isSuccess) {
        return Task.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Erro ao criar tarefa');
      }
    } catch (e) {
      throw Exception('Falha ao criar tarefa: ${e.toString()}');
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    try {
      final response = await _httpClient.put(
        '${RoutesApi.tasks}/${task.id}',
        data: task.toJson(),
      );

      if (response.isSuccess) {
        return Task.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Erro ao atualizar tarefa');
      }
    } catch (e) {
      throw Exception('Falha ao atualizar tarefa: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final response = await _httpClient.delete('${RoutesApi.tasks}/$id');

      if (!response.isSuccess) {
        throw Exception(response.message ?? 'Erro ao deletar tarefa');
      }
    } catch (e) {
      throw Exception('Falha ao deletar tarefa: ${e.toString()}');
    }
  }
}
