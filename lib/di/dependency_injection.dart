import 'package:fiap_farms/data/repositories/goals_repository_impl.dart';
import 'package:fiap_farms/domain/repositories/goals_repository.dart';
import 'package:fiap_farms/domain/usecases/change_password_usecase.dart';
import 'package:fiap_farms/domain/usecases/goals_usecases.dart';
import 'package:fiap_farms/domain/usecases/register_usecase.dart';
import 'package:fiap_farms/presentation/controllers/goals_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  GoalRepository get goalRepository => GoalRepositoryImpl();

  // Use Cases
  SignInUseCase get signInUseCase => SignInUseCase(authRepository);
  SignOutUseCase get signOutUseCase => SignOutUseCase(authRepository);
  GetCurrentUserUseCase get getCurrentUserUseCase =>
      GetCurrentUserUseCase(authRepository);

  RegisterUserUseCase get getRegisterUserUseCase =>
      RegisterUserUseCaseImpl(repository: authRepository);

  ChangePasswordUseCase get getChangePasswordUseCase =>
      ChangePasswordUseCaseImpl(repository: authRepository);

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

  // Goal Use Cases
  CreateGoalUseCase get createGoalUseCase => CreateGoalUseCase(goalRepository);
  GetGoalsUseCase get getGoalsUseCase => GetGoalsUseCase(goalRepository);
  GetGoalByIdUseCase get getGoalByIdUseCase =>
      GetGoalByIdUseCase(goalRepository);
  UpdateGoalUseCase get updateGoalUseCase => UpdateGoalUseCase(goalRepository);
  DeleteGoalUseCase get deleteGoalUseCase => DeleteGoalUseCase(goalRepository);
  GetGoalsByTypeUseCase get getGoalsByTypeUseCase =>
      GetGoalsByTypeUseCase(goalRepository);
  GetActiveGoalsUseCase get getActiveGoalsUseCase =>
      GetActiveGoalsUseCase(goalRepository);
  GetGoalsByStatusUseCase get getGoalsByStatusUseCase =>
      GetGoalsByStatusUseCase(goalRepository);
  UpdateGoalProgressUseCase get updateGoalProgressUseCase =>
      UpdateGoalProgressUseCase(goalRepository);
  CompleteGoalUseCase get completeGoalUseCase =>
      CompleteGoalUseCase(goalRepository);

  // Controllers
  AuthController get authController => AuthController(
    signInUseCase: signInUseCase,
    signOutUseCase: signOutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    registerUserUseCase: getRegisterUserUseCase,
    changePasswordUseCase: getChangePasswordUseCase,
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

  SalesController Function(BuildContext) get salesController =>
      (context) => SalesController(
        context: context,
        createSalesRecordUseCase: createSalesRecordUseCase,
        getSalesRecordsUseCase: getSalesRecordsUseCase,
        getSalesRecordsByDateRangeUseCase: getSalesRecordsByDateRangeUseCase,
        updateSalesRecordUseCase: updateSalesRecordUseCase,
        deleteSalesRecordUseCase: deleteSalesRecordUseCase,
        getGoalsByStatusUseCase: getGoalsByStatusUseCase,
        updateGoalProgressUseCase: updateGoalProgressUseCase,
        completeGoalUseCase: completeGoalUseCase,
      );

  InventoryController Function(BuildContext) get inventoryController =>
      (context) => InventoryController(
        context: context,
        createInventoryItemUseCase: createInventoryItemUseCase,
        getInventoryItemsUseCase: getInventoryItemsUseCase,
        getInventoryItemByProductIdUseCase: getInventoryItemByProductIdUseCase,
        updateInventoryItemUseCase: updateInventoryItemUseCase,
        addToInventoryUseCase: addToInventoryUseCase,
        removeFromInventoryUseCase: removeFromInventoryUseCase,
        getGoalsByStatusUseCase: getGoalsByStatusUseCase,
        updateGoalProgressUseCase: updateGoalProgressUseCase,
        completeGoalUseCase: completeGoalUseCase,
        getActiveGoalsUseCase: getActiveGoalsUseCase,
      );

  GoalController get goalController => GoalController(
    createGoalUseCase: createGoalUseCase,
    getGoalsUseCase: getGoalsUseCase,
    getGoalByIdUseCase: getGoalByIdUseCase,
    updateGoalUseCase: updateGoalUseCase,
    deleteGoalUseCase: deleteGoalUseCase,
    getGoalsByTypeUseCase: getGoalsByTypeUseCase,
    getGoalsByStatusUseCase: getGoalsByStatusUseCase,
    updateGoalProgressUseCase: updateGoalProgressUseCase,
    completeGoalUseCase: completeGoalUseCase,
  );
}
