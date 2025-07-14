import 'package:fiap_farms/domain/entities/register_user.dart';
import 'package:fiap_farms/domain/entities/user.dart';
import 'package:fiap_farms/domain/usecases/auth_usecases.dart';
import 'package:fiap_farms/domain/usecases/register_usecase.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final RegisterUserUseCase _registerUserUseCase;

  AuthController({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required RegisterUserUseCase registerUserUseCase,
  }) : _signInUseCase = signInUseCase,
       _signOutUseCase = signOutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _registerUserUseCase = registerUserUseCase;

  User? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _signInUseCase.execute(email, password);
      _currentUser = User(
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role ?? 'user', // Garante um valor padrão
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _signOutUseCase.execute();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkCurrentUser() async {
    try {
      _currentUser = await _getCurrentUserUseCase.execute();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validações
      if (password.length < 6) {
        throw Exception('A senha deve ter pelo menos 6 caracteres');
      }

      // Cria o objeto de parâmetros
      final params = RegisterUserParams(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      // Chama o use case com os parâmetros
      _currentUser = await _registerUserUseCase.execute(params);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Métodos auxiliares
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
