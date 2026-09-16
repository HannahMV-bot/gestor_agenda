import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel.name({
    required super.id,
    required super.name,
    required super.lastName,
    required super.email,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel.name(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}