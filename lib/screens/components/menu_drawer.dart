import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../routes.dart';

class MenuDrawer extends StatelessWidget {
  final String currentRoute;

  const MenuDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildNavigationItems(context),
          const Divider(),
          _buildFeatureItems(context),
          const Divider(),
          _buildUserItems(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(color: AppColors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.white,
            child: Icon(Icons.agriculture, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          const Text(
            'FIAP Farms',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Cooperativa de Fazendas',
            style: TextStyle(color: AppColors.textWhite70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dashboard, color: AppColors.primary),
          title: const Text('Dashboard de Vendas'),
          selected: currentRoute == Routes.dashboard,
          onTap: () {
            Navigator.pop(context);
            if (currentRoute != Routes.dashboard) {
              Navigator.pushReplacementNamed(context, Routes.dashboard);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.agriculture, color: AppColors.primary),
          title: const Text('Dashboard de Produção'),
          selected: currentRoute == Routes.productionDashboard,
          onTap: () {
            Navigator.pop(context);
            if (currentRoute != Routes.productionDashboard) {
              Navigator.pushReplacementNamed(
                context,
                Routes.productionDashboard,
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.add_box, color: AppColors.primary),
          title: const Text('Cadastrar Produto'),
          selected: currentRoute == Routes.addProduct,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.addProduct);
          },
        ),
      ],
    );
  }

  Widget _buildFeatureItems(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.inventory, color: AppColors.primary),
          title: const Text('Controle de Estoque e Vendas'),
          selected: currentRoute == Routes.inventorySales,
          onTap: () {
            Navigator.pop(context);
            if (currentRoute != Routes.inventorySales) {
              Navigator.pushReplacementNamed(context, Routes.inventorySales);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.flag, color: AppColors.primary),
          title: const Text('Metas e Notificações'),
          onTap: () {
            Navigator.pop(context);
            _showFeatureInDevelopment(context, 'Metas e Notificações');
          },
        ),
      ],
    );
  }

  Widget _buildUserItems(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person, color: AppColors.primary),
          title: const Text('Perfil'),
          onTap: () {
            Navigator.pop(context);
            _showFeatureInDevelopment(context, 'Perfil');
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.danger),
          title: const Text('Sair', style: TextStyle(color: AppColors.danger)),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, Routes.login);
          },
        ),
      ],
    );
  }

  void _showFeatureInDevelopment(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName - Funcionalidade em desenvolvimento'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
