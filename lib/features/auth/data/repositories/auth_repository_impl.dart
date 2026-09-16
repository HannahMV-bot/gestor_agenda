import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<User> login(
    String email,
    String password,
  ) async {
    final response = await remoteDataSource.login(
      email,
      password,
    );

    return UserModel.fromJson(
      response['user'],
    );
  }

  Future<Map<String, dynamic>> loginWithToken(
    String email,
    String password,
  ) async {
    return await remoteDataSource.login(
      email,
      password,
    );
  }

  @override
  Future<void> register(
    String name,
    String lastName,
    String email,
    String password,
  ) async {
    await remoteDataSource.register(
      name,
      lastName,
      email,
      password,
    );
  }
}