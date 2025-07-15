import 'package:fiap_farms/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/controllers/auth_controller.dart';
import '../routes.dart';
import 'components/custom_button.dart';
import 'components/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool isFirstLogin;

  const ChangePasswordScreen({super.key, this.isFirstLogin = false});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();

  static Route route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      builder: (_) =>
          ChangePasswordScreen(isFirstLogin: args?['isFirstLogin'] ?? false),
    );
  }
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FC),
      appBar: widget.isFirstLogin
          ? null
          : AppBar(
              title: const Text('Alterar Senha'),
              backgroundColor: AppColors.primary[800],
            ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (widget.isFirstLogin) ...[
                  Text(
                    'Bem-vindo ao FIAP Farms',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Por segurança, defina uma nova senha',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                ],
                if (!widget.isFirstLogin) ...[
                  const SizedBox(height: 40),
                  Text(
                    'Alterar Senha',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary[800],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
                if (!widget.isFirstLogin)
                  CustomTextField.large(
                    controller: _currentPasswordController,
                    labelText: 'Senha Atual',
                    hintText: 'Digite sua senha atual',
                    isPassword: true,
                    prefixIcon: Icons.lock,
                    variant: TextFieldVariant.filled,
                    borderRadius: BorderRadius.circular(30.0),
                    isRequired: true,
                  ),
                if (!widget.isFirstLogin) const SizedBox(height: 20),
                CustomTextField.large(
                  controller: _newPasswordController,
                  labelText: 'Nova Senha',
                  hintText: 'Digite a nova senha',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  variant: TextFieldVariant.filled,
                  borderRadius: BorderRadius.circular(30.0),
                  isRequired: true,
                ),
                const SizedBox(height: 20),
                CustomTextField.large(
                  controller: _confirmPasswordController,
                  labelText: 'Confirmar Nova Senha',
                  hintText: 'Confirme a nova senha',
                  isPassword: true,
                  prefixIcon: Icons.lock_reset,
                  variant: TextFieldVariant.filled,
                  borderRadius: BorderRadius.circular(30.0),
                  isRequired: true,
                ),
                const SizedBox(height: 30),
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return Column(
                      children: [
                        CustomButton.large(
                          onPressed: () => _changePassword(authController),
                          text: widget.isFirstLogin
                              ? 'Definir Nova Senha'
                              : 'Alterar Senha',
                          variant: ButtonVariant.primary,
                          isLoading: authController.isLoading,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        const SizedBox(height: 10),
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

  Future<void> _changePassword(AuthController authController) async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      authController.setError('As senhas não coincidem');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      authController.setError('A senha deve ter pelo menos 6 caracteres');
      return;
    }

    try {
      final success = await authController.changePassword(
        currentPassword: widget.isFirstLogin
            ? null
            : _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        isFirstLogin: widget.isFirstLogin,
      );

      if (success && mounted) {
        if (widget.isFirstLogin) {
          // Aguarda a atualização completa do estado
          await Future.delayed(const Duration(seconds: 1));

          // Navegação segura com limpeza de stack
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.dashboard, (route) => false);
        } else {
          Navigator.pop(context);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Senha alterada com sucesso!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
