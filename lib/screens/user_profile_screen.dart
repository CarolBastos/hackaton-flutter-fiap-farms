import 'package:fiap_farms/screens/components/custom_app_bar.dart';
import 'package:fiap_farms/screens/components/menu_drawer.dart';
import 'package:fiap_farms/screens/components/user_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../routes.dart';
import '../presentation/controllers/auth_controller.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final currentUser = authController.currentUser;

    return Scaffold(
      appBar: DashboardAppBar(title: 'Meu Perfil'),
      drawer: MenuDrawer(currentRoute: Routes.userDetails),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserHeader(),
            const SizedBox(height: 24),

            // Card de Informações do Usuário
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações do Usuário',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _ProfileInfoItem(
                      icon: Icons.person,
                      label: 'Nome',
                      value: currentUser?.name ?? 'Não informado',
                    ),

                    const Divider(height: 24),

                    _ProfileInfoItem(
                      icon: Icons.email,
                      label: 'E-mail',
                      value: currentUser?.email ?? 'Não informado',
                    ),

                    const Divider(height: 24),

                    _ProfileInfoItem(
                      icon: Icons.work,
                      label: 'Tipo de Conta',
                      value: currentUser?.role ?? 'Não informado',
                    ),

                    const Divider(height: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botão de Alterar Senha
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.changePassword);
                },
                icon: const Icon(Icons.lock_reset, size: 24),
                label: const Text(
                  'Alterar Senha',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botão de Sair
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authController.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.login,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, size: 24),
                label: const Text('Sair', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  foregroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
