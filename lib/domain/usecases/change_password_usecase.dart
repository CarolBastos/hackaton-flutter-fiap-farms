import '../repositories/auth_repository.dart';

abstract class ChangePasswordUseCase {
  Future<bool> execute({
    String? currentPassword,
    required String newPassword,
    bool isFirstLogin = false,
  });
}

class ChangePasswordUseCaseImpl implements ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCaseImpl({required this.repository});

  @override
  Future<bool> execute({
    String? currentPassword,
    required String newPassword,
    bool isFirstLogin = false,
  }) async {
    return await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      isFirstLogin: isFirstLogin,
    );
  }
}