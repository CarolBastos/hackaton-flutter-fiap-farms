import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/sales_repository_impl.dart';
import '../data/repositories/product_repository_impl.dart';
import '../data/repositories/production_repository_impl.dart';
import '../data/repositories/inventory_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/sales_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/production_repository.dart';
import '../domain/repositories/inventory_repository.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/sales_usecases.dart';
import '../domain/usecases/product_usecases.dart';
import '../domain/usecases/production_usecases.dart';
import '../domain/usecases/inventory_usecases.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/product_controller.dart';
import '../presentation/controllers/production_controller.dart';
import '../presentation/controllers/sales_controller.dart';
import '../presentation/controllers/inventory_controller.dart';

class DependencyInjection {
  static final DependencyInjection _instance = DependencyInjection._internal();
  factory DependencyInjection() => _instance;
  DependencyInjection._internal();

  // Repositories
  AuthRepository get authRepository =>
      AuthRepositoryImpl(firebaseAuth: FirebaseAuth.instance);

  SalesRepository get salesRepository => SalesRepositoryImpl();

  ProductRepository get productRepository => ProductRepositoryImpl();
  ProductionRepository get productionRepository => ProductionRepositoryImpl();
  InventoryRepository get inventoryRepository => InventoryRepositoryImpl();

  // Use Cases
  SignInUseCase get signInUseCase => SignInUseCase(authRepository);
  SignOutUseCase get signOutUseCase => SignOutUseCase(authRepository);
  GetCurrentUserUseCase get getCurrentUserUseCase =>
      GetCurrentUserUseCase(authRepository);

  GetSalesDataUseCase get getSalesDataUseCase =>
      GetSalesDataUseCase(salesRepository);
  GetTopProductsUseCase get getTopProductsUseCase =>
      GetTopProductsUseCase(salesRepository);

  // Sales Record Use Cases
  CreateSalesRecordUseCase get createSalesRecordUseCase =>
      CreateSalesRecordUseCase(salesRepository);
  GetSalesRecordsUseCase get getSalesRecordsUseCase =>
      GetSalesRecordsUseCase(salesRepository);
  GetSalesRecordsByDateRangeUseCase get getSalesRecordsByDateRangeUseCase =>
      GetSalesRecordsByDateRangeUseCase(salesRepository);
  UpdateSalesRecordUseCase get updateSalesRecordUseCase =>
      UpdateSalesRecordUseCase(salesRepository);
  DeleteSalesRecordUseCase get deleteSalesRecordUseCase =>
      DeleteSalesRecordUseCase(salesRepository);

  CreateProductUseCase get createProductUseCase =>
      CreateProductUseCase(productRepository);
  GetProductsUseCase get getProductsUseCase =>
      GetProductsUseCase(productRepository);

  CreateProductionBatchUseCase get createProductionBatchUseCase =>
      CreateProductionBatchUseCase(productionRepository);
  GetProductionBatchesUseCase get getProductionBatchesUseCase =>
      GetProductionBatchesUseCase(productionRepository);
  GetProductionBatchesByStatusUseCase get getProductionBatchesByStatusUseCase =>
      GetProductionBatchesByStatusUseCase(productionRepository);
  UpdateProductionStatusUseCase get updateProductionStatusUseCase =>
      UpdateProductionStatusUseCase(productionRepository);

  // Inventory Use Cases
  CreateInventoryItemUseCase get createInventoryItemUseCase =>
      CreateInventoryItemUseCase(inventoryRepository);
  GetInventoryItemsUseCase get getInventoryItemsUseCase =>
      GetInventoryItemsUseCase(inventoryRepository);
  GetInventoryItemByProductIdUseCase get getInventoryItemByProductIdUseCase =>
      GetInventoryItemByProductIdUseCase(inventoryRepository);
  UpdateInventoryItemUseCase get updateInventoryItemUseCase =>
      UpdateInventoryItemUseCase(inventoryRepository);
  AddToInventoryUseCase get addToInventoryUseCase =>
      AddToInventoryUseCase(inventoryRepository);
  RemoveFromInventoryUseCase get removeFromInventoryUseCase =>
      RemoveFromInventoryUseCase(inventoryRepository);

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

  ProductionController get productionController => ProductionController(
    createProductionBatchUseCase: createProductionBatchUseCase,
    getProductionBatchesUseCase: getProductionBatchesUseCase,
    getProductionBatchesByStatusUseCase: getProductionBatchesByStatusUseCase,
    updateProductionStatusUseCase: updateProductionStatusUseCase,
  );

  SalesController get salesController => SalesController(
    createSalesRecordUseCase: createSalesRecordUseCase,
    getSalesRecordsUseCase: getSalesRecordsUseCase,
    getSalesRecordsByDateRangeUseCase: getSalesRecordsByDateRangeUseCase,
    updateSalesRecordUseCase: updateSalesRecordUseCase,
    deleteSalesRecordUseCase: deleteSalesRecordUseCase,
  );

  InventoryController get inventoryController => InventoryController(
    createInventoryItemUseCase: createInventoryItemUseCase,
    getInventoryItemsUseCase: getInventoryItemsUseCase,
    getInventoryItemByProductIdUseCase: getInventoryItemByProductIdUseCase,
    updateInventoryItemUseCase: updateInventoryItemUseCase,
    addToInventoryUseCase: addToInventoryUseCase,
    removeFromInventoryUseCase: removeFromInventoryUseCase,
  );
}
