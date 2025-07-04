import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<User> execute(String email, String password) {
    if (email.isEmpty) {
      throw Exception('Email é obrigatório');
    }
    if (password.isEmpty) {
      throw Exception('Senha é obrigatória');
    }

    return repository.signInWithEmailAndPassword(email, password);
  }
}

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> execute() {
    return repository.signOut();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> execute() {
    return repository.getCurrentUser();
  }
}
