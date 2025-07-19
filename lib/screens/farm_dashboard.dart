import 'package:fiap_farms/domain/entities/farm.dart';
import 'package:fiap_farms/presentation/controllers/farm_controller.dart';
import 'package:fiap_farms/screens/farm_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../routes.dart';
import 'components/menu_drawer.dart';
import 'components/custom_app_bar.dart';

class FarmDashboard extends StatefulWidget {
  const FarmDashboard({super.key});

  @override
  State<FarmDashboard> createState() => _FarmDashboardState();
}

class _FarmDashboardState extends State<FarmDashboard> {
  late Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<FarmController>(context, listen: false);
    _initializeFuture = controller.initializeFarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardAppBar(title: 'Dashboard de Fazendas'),
      drawer: MenuDrawer(currentRoute: Routes.farmDashboard),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.addFarm),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<FarmController>(
        builder: (context, controller, _) {
          return FutureBuilder<void>(
            future: _initializeFuture,
            builder: (context, snapshot) {
              if (controller.isLoading && controller.farms.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    'Erro: ${controller.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.reloadFarms();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildSummaryCards(controller),
                      const SizedBox(height: 24),
                      _buildFarmsList(controller),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(FarmController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isWide ? 1.2 : 0.9, // mais altura nos estreitos
          ),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _SummaryCard(
                title: 'Fazendas',
                count: controller.farms.length,
                icon: Icons.agriculture,
                color: AppColors.primary,
                emoji: '🏡',
              );
            } else {
              return _SummaryCard(
                title: 'Produção Anual',
                value: controller.totalProduction,
                unit: 'ton',
                icon: Icons.assessment,
                color: AppColors.success,
                emoji: '📊',
              );
            }
          },
        );
      },
    );
  }

  Widget _buildFarmsList(FarmController controller) {
    final farms = controller.farms;

    if (farms.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma fazenda cadastrada',
              style: TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fazendas (${farms.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: farms.length,
          itemBuilder: (context, index) {
            final farm = farms[index];
            return _FarmCard(farm: farm);
          },
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int? count;
  final double? value;
  final String? unit;
  final IconData icon;
  final Color color;
  final String emoji;

  const _SummaryCard({
    required this.title,
    this.count,
    this.value,
    this.unit,
    required this.icon,
    required this.color,
    required this.emoji,
  }) : assert(count != null || value != null);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 6),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                count != null
                    ? count.toString()
                    : '${value!.toStringAsFixed(1)} ${unit ?? ''}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmCard extends StatelessWidget {
  final Farm farm;

  const _FarmCard({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navegar para tela de detalhes com mapa interativo
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FarmDetailsScreen(farm: farm),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini mapa estático
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      farm.staticMapUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.map_outlined),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Produto: ${_capitalize(farm.productType)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Produção anual: ${farm.annualProduction.toStringAsFixed(1)} ton',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (farm.address != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            farm.address!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (farm.area != null || farm.establishedDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (farm.area != null) ...[
                      Icon(
                        Icons.landscape,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Área: ${farm.area!.toStringAsFixed(1)} ha',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (farm.establishedDate != null) ...[
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Fundação: ${_formatDate(farm.establishedDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
