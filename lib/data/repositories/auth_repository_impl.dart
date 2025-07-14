import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    firebase.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

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

      // Obter dados adicionais do Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Criar objeto User com dados do Firestore
      return User(
        id: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name:
            userDoc.data()?['displayName'] ??
            userCredential.user!.displayName ??
            '',
        role: userDoc.data()?['role'] ?? 'admin', // Garante um valor padrão
      );
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
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // 1. Criar usuário no Firebase Authentication
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Falha no registro do usuário');
      }

      // 2. Criar objeto User com os dados fornecidos
      final user = User(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
      );

      // 3. Salvar informações adicionais no Firestore
      await _firestore.collection('users').doc(user.id).set({
        'email': user.email,
        'displayName': user.name,
        'createdAt': FieldValue.serverTimestamp(),
        'role': user.role,
      });

      return user;
    } on firebase.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email já está em uso');
        case 'invalid-email':
          throw Exception('Email inválido');
        case 'operation-not-allowed':
          throw Exception('Operação não permitida');
        case 'weak-password':
          throw Exception('Senha fraca (mínimo 6 caracteres)');
        default:
          throw Exception('Erro no registro: ${e.message}');
      }
    } on FirebaseException catch (e) {
      throw Exception('Erro ao salvar dados do usuário: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido: $e');
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

    // Obter dados adicionais do Firestore
    final userDoc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: userDoc.data()?['displayName'] ?? firebaseUser.displayName ?? '',
      role: userDoc.data()?['role'] ?? 'admin',
    );
  }
}
