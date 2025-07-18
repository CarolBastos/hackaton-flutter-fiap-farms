import 'package:fiap_farms/presentation/controllers/farm_controller.dart';
import 'package:fiap_farms/presentation/controllers/goals_controller.dart';
import 'package:fiap_farms/screens/add_farm_screen.dart';
import 'package:fiap_farms/screens/add_goals_screen.dart';
import 'package:fiap_farms/screens/change_password_screen.dart';
import 'package:fiap_farms/screens/farm_dashboard.dart';
import 'package:fiap_farms/screens/register_screen.dart';
import 'package:fiap_farms/screens/sales_dashboard.dart';
import 'package:fiap_farms/screens/login_screen.dart';
import 'package:fiap_farms/screens/add_product_screen.dart';
import 'package:fiap_farms/screens/production_dashboard.dart';
import 'package:fiap_farms/screens/add_production_screen.dart';
import 'package:fiap_farms/screens/inventory_sales_screen.dart';
import 'package:fiap_farms/screens/goals_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:provider/provider.dart';
import 'di/dependency_injection.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/product_controller.dart';
import 'presentation/controllers/production_controller.dart';
import 'presentation/controllers/sales_controller.dart';
import 'presentation/controllers/inventory_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final di = DependencyInjection();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
          create: (_) => di.authController,
        ),
        ChangeNotifierProvider<ProductController>(
          create: (_) => di.productController,
        ),
        ChangeNotifierProvider<FarmController>(
          create: (_) => di.farmController(),
        ),
        ChangeNotifierProvider<ProductionController>(
          create: (_) => di.productionController,
        ),
        ChangeNotifierProvider<SalesController>(
          create: (context) => di.salesController(context),
        ),
        ChangeNotifierProvider<InventoryController>(
          create: (context) => di.inventoryController(context),
        ),
        ChangeNotifierProvider<GoalController>(
          create: (_) => di.goalController,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIAP Farms',
      initialRoute: Routes.login,
      builder: (context, child) {
        return SafeArea(
          // Configuração personalizada do SafeArea
          top: false,
          bottom: true,
          left: true,
          right: true,
          minimum: const EdgeInsets.only(bottom: 16),
          child: child!,
        );
      },
      routes: {
        Routes.dashboard: (context) => const SalesDashboard(),
        Routes.login: (context) => const LoginScreen(),
        Routes.addProduct: (context) => const AddProductScreen(),
        Routes.productionDashboard: (context) => const ProductionDashboard(),
        Routes.addProduction: (context) => const AddProductionScreen(),
        Routes.inventorySales: (context) => const InventorySalesScreen(),
        Routes.adminRegister: (context) => const AdminRegisterScreen(),
        Routes.changePassword: (context) => const ChangePasswordScreen(),
        Routes.goalsDashboard: (context) => const GoalsDashboard(),
        Routes.addGoal: (context) => const AddGoalScreen(),
        Routes.farmDashboard: (context) => const FarmDashboard(),
        Routes.addFarm: (context) => const AddFarmScreen(),
      },
    );
  }
}
