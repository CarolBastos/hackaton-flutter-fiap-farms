import 'package:fiap_farms/routes.dart';
import 'package:fiap_farms/screens/components/custom_app_bar.dart';
import 'package:fiap_farms/screens/components/menu_drawer.dart';
import 'package:fiap_farms/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/controllers/auth_controller.dart';
import 'components/custom_button.dart';
import 'components/custom_text_field.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedRole = 'user';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminPermission();
  }

  void _checkAdminPermission() {
    final authController = Provider.of<AuthController>(context, listen: false);
    setState(() {
      _isAdmin = authController.currentUser?.role == 'admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F3FC),
        appBar: AppBar(
          title: const Text('Acesso Restrito'),
          backgroundColor: AppColors.error,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 60, color: AppColors.error),
                const SizedBox(height: 20),
                const Text(
                  'Acesso não autorizado',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Somente administradores podem cadastrar novos usuários',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                CustomButton.large(
                  onPressed: () => Navigator.pop(context),
                  text: 'Voltar',
                  variant: ButtonVariant.secondary,
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FC),
      appBar: DashboardAppBar(title: 'Cadastrar Novo Usuário'),
      drawer: MenuDrawer(currentRoute: Routes.adminRegister),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20.0),
                CustomTextField.large(
                  controller: _nameController,
                  labelText: 'Nome Completo',
                  hintText: 'Digite o nome completo',
                  keyboardType: TextInputType.name,
                  prefixIcon: Icons.person,
                  variant: TextFieldVariant.filled,
                  borderRadius: BorderRadius.circular(30.0),
                  isRequired: true,
                ),
                const SizedBox(height: 20.0),
                CustomTextField.large(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Digite o email',
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
                  hintText: 'Digite a senha',
                  isPassword: true,
                  prefixIcon: Icons.lock,
                  variant: TextFieldVariant.filled,
                  borderRadius: BorderRadius.circular(30.0),
                  isRequired: true,
                ),
                const SizedBox(height: 20.0),
                CustomTextField.large(
                  controller: _confirmPasswordController,
                  labelText: 'Confirmar Senha',
                  hintText: 'Confirme a senha',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  variant: TextFieldVariant.filled,
                  borderRadius: BorderRadius.circular(30.0),
                  isRequired: true,
                ),
                const SizedBox(height: 20.0),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Usuário',
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'user',
                      child: Text('Usuário Comum'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrador'),
                    ),
                    DropdownMenuItem(value: 'manager', child: Text('Gerente')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 30.0),
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return Column(
                      children: [
                        CustomButton.large(
                          onPressed: () => _registerUser(authController),
                          text: 'Cadastrar Usuário',
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
                const SizedBox(height: 20.0),
                CustomButton.large(
                  onPressed: () => Navigator.pop(context),
                  text: 'Voltar',
                  variant: ButtonVariant.secondary,
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _registerUser(AuthController authController) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o nome completo')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas não coincidem')));
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve ter pelo menos 6 caracteres'),
        ),
      );
      return;
    }

    await authController.registerUser(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
    );

    if (authController.isAuthenticated && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
