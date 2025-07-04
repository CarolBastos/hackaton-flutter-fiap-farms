import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/sales_repository_impl.dart';
import '../data/repositories/product_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/sales_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/sales_usecases.dart';
import '../domain/usecases/product_usecases.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/product_controller.dart';

class DependencyInjection {
  static final DependencyInjection _instance = DependencyInjection._internal();
  factory DependencyInjection() => _instance;
  DependencyInjection._internal();

  // Repositories
  AuthRepository get authRepository =>
      AuthRepositoryImpl(firebaseAuth: FirebaseAuth.instance);

  SalesRepository get salesRepository => SalesRepositoryImpl();

  ProductRepository get productRepository => ProductRepositoryImpl();

  // Use Cases
  SignInUseCase get signInUseCase => SignInUseCase(authRepository);
  SignOutUseCase get signOutUseCase => SignOutUseCase(authRepository);
  GetCurrentUserUseCase get getCurrentUserUseCase =>
      GetCurrentUserUseCase(authRepository);

  GetSalesDataUseCase get getSalesDataUseCase =>
      GetSalesDataUseCase(salesRepository);
  GetTopProductsUseCase get getTopProductsUseCase =>
      GetTopProductsUseCase(salesRepository);

  CreateProductUseCase get createProductUseCase =>
      CreateProductUseCase(productRepository);
  GetProductsUseCase get getProductsUseCase =>
      GetProductsUseCase(productRepository);

  // Controllers
  AuthController get authController => AuthController(
    signInUseCase: signInUseCase,
    signOutUseCase: signOutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );

  ProductController get productController => ProductController(
    createProductUseCase: createProductUseCase,
    getProductsUseCase: getProductsUseCase,
  );
}
