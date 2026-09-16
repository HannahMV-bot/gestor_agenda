import '../../domain/entities/task.dart';
import '../../domain/repositories/agenda_repository.dart';
import '../datasources/agenda_remote_data_source.dart';
import '../models/task_model.dart';

class AgendaRepositoryImpl implements AgendaRepository {
  final AgendaRemoteDataSource remoteDataSource;

  AgendaRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Task>> getTasks() async {
    final response =
        await remoteDataSource.getTasks();

    return response
        .map(
          (json) => TaskModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<Task> createTask(
    Task task,
  ) async {
    final response =
        await remoteDataSource.createTask(
      TaskModel(
        id: task.id,
        userId: task.userId,
        title: task.title,
        description: task.description,
        date: task.date,
        time: task.time,
        status: task.status,
        priority: task.priority,
      ).toJson(),
    );

    return TaskModel(
      id: response['task_id'] ?? '',
      userId: task.userId,
      title: task.title,
      description: task.description,
      date: task.date,
      time: task.time,
      status: task.status,
      priority: task.priority,
    );
  }

  @override
  Future<Task> updateTask(
    Task task,
  ) async {
    await remoteDataSource.updateTask(
      task.id,
      TaskModel(
        id: task.id,
        userId: task.userId,
        title: task.title,
        description: task.description,
        date: task.date,
        time: task.time,
        status: task.status,
        priority: task.priority,
      ).toJson(),
    );

    return task;
  }

  @override
  Future<void> deleteTask(
    String taskId,
  ) async {
    await remoteDataSource.deleteTask(
      taskId,
    );
  }
}