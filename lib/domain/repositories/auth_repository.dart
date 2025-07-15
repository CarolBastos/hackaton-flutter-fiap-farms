import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  });
  Future<bool> changePassword({
    String? currentPassword,
    required String newPassword,
    bool isFirstLogin = false,
  });
}
