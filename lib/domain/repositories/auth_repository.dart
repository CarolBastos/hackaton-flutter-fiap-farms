import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<User?> getCurrentUser();
}
