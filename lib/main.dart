import 'package:fiap_farms/screens/dashboard.dart';
import 'package:fiap_farms/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:provider/provider.dart';
import 'di/dependency_injection.dart';
import 'presentation/controllers/auth_controller.dart';

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
      },
    );
  }
}
