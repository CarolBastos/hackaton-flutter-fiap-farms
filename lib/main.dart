import 'package:fiap_farms/screens/dashboard.dart';
import 'package:fiap_farms/screens/login_screen.dart';
import 'package:fiap_farms/screens/add_product_screen.dart';
import 'package:fiap_farms/screens/production_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:provider/provider.dart';
import 'di/dependency_injection.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/product_controller.dart';
import 'presentation/controllers/production_controller.dart';

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
        ChangeNotifierProvider<ProductionController>(
          create: (_) => di.productionController,
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
      routes: {
        Routes.dashboard: (context) => DashboardScreen(),
        Routes.login: (context) => const LoginScreen(),
        Routes.addProduct: (context) => const AddProductScreen(),
        Routes.productionDashboard: (context) => const ProductionDashboard(),
      },
    );
  }
}
