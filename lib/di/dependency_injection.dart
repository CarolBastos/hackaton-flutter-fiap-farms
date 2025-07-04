import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/sales_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/sales_repository.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/sales_usecases.dart';
import '../presentation/controllers/auth_controller.dart';

class DependencyInjection {
  static final DependencyInjection _instance = DependencyInjection._internal();
  factory DependencyInjection() => _instance;
  DependencyInjection._internal();

  // Repositories
  AuthRepository get authRepository =>
      AuthRepositoryImpl(firebaseAuth: FirebaseAuth.instance);

  SalesRepository get salesRepository => SalesRepositoryImpl();

  // Use Cases
  SignInUseCase get signInUseCase => SignInUseCase(authRepository);
  SignOutUseCase get signOutUseCase => SignOutUseCase(authRepository);
  GetCurrentUserUseCase get getCurrentUserUseCase =>
      GetCurrentUserUseCase(authRepository);

  GetSalesDataUseCase get getSalesDataUseCase =>
      GetSalesDataUseCase(salesRepository);
  GetTopProductsUseCase get getTopProductsUseCase =>
      GetTopProductsUseCase(salesRepository);

  // Controllers
  AuthController get authController => AuthController(
    signInUseCase: signInUseCase,
    signOutUseCase: signOutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );
}
