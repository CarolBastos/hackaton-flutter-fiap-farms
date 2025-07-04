import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase.FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({firebase.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance;

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Falha na autenticação');
      }

      return User.fromFirebase(userCredential.user!);
    } on firebase.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Usuário não encontrado');
        case 'wrong-password':
          throw Exception('Senha incorreta');
        case 'invalid-email':
          throw Exception('Email inválido');
        case 'user-disabled':
          throw Exception('Usuário desabilitado');
        default:
          throw Exception('Erro na autenticação: ${e.message}');
      }
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return User.fromFirebase(firebaseUser);
  }
}
