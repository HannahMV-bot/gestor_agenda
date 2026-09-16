import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';

class AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSource({
    required this.apiService,
  });

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return await apiService.post(
      ApiConstants.login,
      {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> register(
    String name,
    String lastName,
    String email,
    String password,
  ) async {
    return await apiService.post(
      ApiConstants.register,
      {
        'name': name,
        'last_name': lastName,
        'email': email,
        'password': password,
      },
    );
  }
}