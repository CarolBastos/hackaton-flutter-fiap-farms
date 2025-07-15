import 'package:fiap_farms/domain/entities/register_user.dart';
import 'package:fiap_farms/domain/entities/user.dart';
import 'package:fiap_farms/domain/usecases/auth_usecases.dart';
import 'package:fiap_farms/domain/usecases/register_usecase.dart';
import 'package:fiap_farms/domain/usecases/change_password_usecase.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  AuthController({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required RegisterUserUseCase registerUserUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
  }) : _signInUseCase = signInUseCase,
       _signOutUseCase = signOutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _registerUserUseCase = registerUserUseCase,
       _changePasswordUseCase = changePasswordUseCase;

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
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
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
      setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkCurrentUser() async {
    try {
      _currentUser = await _getCurrentUserUseCase.execute();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
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
      if (password.length < 6) {
        throw Exception('A senha deve ter pelo menos 6 caracteres');
      }

      final params = RegisterUserParams(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      _currentUser = await _registerUserUseCase.execute(params);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    String? currentPassword,
    required String newPassword,
    bool isFirstLogin = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (newPassword.length < 6) {
        throw Exception('A senha deve ter pelo menos 6 caracteres');
      }

      final success = await _changePasswordUseCase.execute(
        currentPassword: currentPassword,
        newPassword: newPassword,
        isFirstLogin: isFirstLogin,
      );

      if (success) {
        // Atualiza o estado do usuário
        if (isFirstLogin) {
          _currentUser = _currentUser?.copyWith(firstLogin: false);
        }
        // Força uma nova verificação do usuário
        await _getCurrentUserUseCase.execute().then((user) {
          _currentUser = user;
          notifyListeners();
        });
      }

      return success;
    } catch (e) {
      setError('Erro ao alterar senha: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
