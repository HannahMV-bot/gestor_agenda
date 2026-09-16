import '../entities/task.dart';

abstract class AgendaRepository {
  Future<List<Task>> getTasks();

  Future<Task> createTask(
    Task task,
  );

  Future<Task> updateTask(
    Task task,
  );

  Future<void> deleteTask(
    String taskId,
  );
}