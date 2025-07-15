import 'package:fiap_farms/screens/change_password_screen.dart';
import 'package:fiap_farms/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/controllers/auth_controller.dart';
import '../routes.dart';
import 'components/custom_button.dart';
import 'components/custom_text_field.dart';

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
      backgroundColor: const Color(0xFFF7F3FC),
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
                CustomTextField.large(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Digite seu email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  variant: TextFieldVariant.filled,
                  borderRadius: BorderRadius.circular(30.0),
                  isRequired: true,
                ),
                const SizedBox(height: 20.0),
                CustomTextField.large(
                  controller: _passwordController,
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                  isPassword: true,
                  prefixIcon: Icons.lock,
                  variant: TextFieldVariant.filled,
                  borderRadius: BorderRadius.circular(30.0),
                  isRequired: true,
                ),
                const SizedBox(height: 20.0),
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return Column(
                      children: [
                        CustomButton.large(
                          onPressed: () => _login(authController),
                          text: 'Entrar',
                          variant: ButtonVariant.primary,
                          isLoading: authController.isLoading,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        const SizedBox(height: 10.0),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login(AuthController authController) async {
    await authController.signIn(
      _emailController.text,
      _passwordController.text,
    );

    if (authController.isAuthenticated && mounted) {
      // Aguarda a conclusão de qualquer operação pendente
      await Future.delayed(const Duration(milliseconds: 500));

      if (authController.currentUser?.firstLogin == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChangePasswordScreen(isFirstLogin: true),
          ),
        );
      } else {
        Navigator.of(context).pushReplacementNamed(Routes.dashboard);
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
