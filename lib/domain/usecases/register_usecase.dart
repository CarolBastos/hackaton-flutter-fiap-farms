import 'package:fiap_farms/domain/entities/register_user.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

abstract class RegisterUserUseCase {
  Future<User> execute(RegisterUserParams params);
}

class RegisterUserUseCaseImpl implements RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCaseImpl({required this.repository});

  @override
  Future<User> execute(RegisterUserParams params) async {
    return await repository.registerUser(
      name: params.name,
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}