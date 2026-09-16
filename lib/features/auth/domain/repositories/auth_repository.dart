import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(
    String email,
    String password,
  );

  Future<void> register(
    String name,
    String lastName,
    String email,
    String password,
  );
}