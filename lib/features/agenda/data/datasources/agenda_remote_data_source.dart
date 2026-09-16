import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';

class AgendaRemoteDataSource {
  final ApiService apiService;

  AgendaRemoteDataSource({
    required this.apiService,
  });

  Future<List<dynamic>> getTasks() async {
    return await apiService.getList(
      '${ApiConstants.baseUrl}/tasks/',
    );
  }

  Future<Map<String, dynamic>> createTask(
    Map<String, dynamic> task,
  ) async {
    return await apiService.post(
      '${ApiConstants.baseUrl}/tasks/',
      task,
    );
  }

  Future<Map<String, dynamic>> updateTask(
    String taskId,
    Map<String, dynamic> task,
  ) async {
    return await apiService.put(
      '${ApiConstants.baseUrl}/tasks/$taskId',
      task,
    );
  }

  Future<Map<String, dynamic>> deleteTask(
    String taskId,
  ) async {
    return await apiService.delete(
      '${ApiConstants.baseUrl}/tasks/$taskId',
    );
  }
}