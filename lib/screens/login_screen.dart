import 'package:fiap_farms/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/controllers/auth_controller.dart';
import '../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FC), // Light purple background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'FIAP Farms',
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary[800],
                  ),
                ),
                const SizedBox(height: 40.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: AppColors.grey,
                    prefixIcon: const Icon(
                      Icons.email,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                // Password TextField
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: AppColors.grey,
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                // Login Button
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: authController.isLoading
                              ? null
                              : () => _login(authController),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 80.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: authController.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Entrar',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                        ),
                        const SizedBox(height: 10.0),
                        // Error Message Display
                        if (authController.errorMessage.isNotEmpty)
                          Text(
                            authController.errorMessage,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14.0,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login(AuthController authController) async {
    await authController.signIn(
      _emailController.text,
      _passwordController.text,
    );

    if (authController.isAuthenticated) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
