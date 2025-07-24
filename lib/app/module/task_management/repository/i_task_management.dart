import 'package:desafio_skillfy/app/module/task_management/models/task_model.dart';

abstract class ITaskManagement {
  Future<List<Task>> getTasks();
  Future<Task?> getTaskById(String id);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
}
