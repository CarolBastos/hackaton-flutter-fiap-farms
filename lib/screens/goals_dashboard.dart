import 'package:fiap_farms/domain/entities/goals.dart';
import 'package:fiap_farms/presentation/controllers/goals_controller.dart';
import 'package:fiap_farms/screens/goal_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../routes.dart';
import 'components/menu_drawer.dart';
import 'components/custom_app_bar.dart';

class GoalsDashboard extends StatefulWidget {
  const GoalsDashboard({super.key});

  @override
  State<GoalsDashboard> createState() => _GoalsDashboardState();
}

class _GoalsDashboardState extends State<GoalsDashboard> {
  late Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<GoalController>(context, listen: false);
    _initializeFuture = controller.initializeGoalsIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardAppBar(title: 'Dashboard de Metas'),
      drawer: MenuDrawer(currentRoute: Routes.goalsDashboard),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.addGoal),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<GoalController>(
        builder: (context, controller, _) {
          return FutureBuilder<void>(
            future: _initializeFuture,
            builder: (context, snapshot) {
              if (controller.isLoading && controller.goals.isEmpty) {
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

              final stats = controller.getGoalStatistics(DateTime.now());

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.reloadGoals();
                  setState(() {
                    _initializeFuture = controller
                        .initializeGoalsIfNeeded(); // opcional
                  });
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildStatusCards(stats),
                      const SizedBox(height: 24),
                      _buildStatusFilters(controller),
                      const SizedBox(height: 16),
                      _buildGoalsList(controller),
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

  Widget _buildStatusCards(GoalStatistics stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final cardWidth = isWide
            ? (constraints.maxWidth - 48) /
                  4 // 4 colunas com 16 de spacing
            : (constraints.maxWidth - 24) / 2; // 2 colunas com 12 de spacing

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatusCard(
              title: 'Planejadas',
              count: stats.plannedCount,
              icon: Icons.schedule,
              color: AppColors.statusPlanejado2,
              emoji: '📅',
              width: cardWidth,
            ),
            _StatusCard(
              title: 'Ativas',
              count: stats.activeCount,
              icon: Icons.trending_up,
              color: AppColors.statusAtivo,
              emoji: '📈',
              width: cardWidth,
            ),
            _StatusCard(
              title: 'Atingidas',
              count: stats.completedCount,
              icon: Icons.check_circle,
              color: AppColors.statusAtingido,
              emoji: '✅',
              width: cardWidth,
            ),
            _StatusCard(
              title: 'Não Atingidas',
              count: stats.canceledCount + stats.pendingCount,
              icon: Icons.cancel,
              color: AppColors.statusNaoAtingido,
              emoji: '❌',
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusFilters(GoalController controller) {
    final statuses = [
      {'name': 'Todos', 'value': ''},
      {'name': 'Planejadas', 'value': 'planejada'},
      {'name': 'Ativas', 'value': 'ativa'},
      {'name': 'Atingidas', 'value': 'atingida'},
      {'name': 'Canceladas', 'value': 'cancelada'},
      {'name': 'Pendentes', 'value': 'pendente'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtrar por Status:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: statuses.map((status) {
              final isSelected =
                  controller.selectedStatusFilter == status['value'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(status['name']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.loadGoalsByStatus(status['value']!);
                    }
                  },
                  backgroundColor: AppColors.greyLight,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList(GoalController controller) {
    final goals = controller.filteredGoals;

    if (goals.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.flag_outlined, size: 64, color: AppColors.textLight),
            SizedBox(height: 16),
            Text(
              'Nenhuma meta encontrada',
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
          'Metas (${goals.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return _GoalCard(goal: goal, controller: controller);
          },
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final String emoji;
  final double? width;

  const _StatusCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.emoji,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Icon(icon, color: color, size: 24),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final GoalController controller;

  const _GoalCard({required this.goal, required this.controller});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(goal.status);
    final progress = goal.currentValue / goal.targetValue;
    final unit = _getUnitDisplay(goal.targetUnit);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  GoalDetailsScreen(goal: goal, controller: controller),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getStatusEmoji(goal.status)),
                        const SizedBox(width: 4),
                        Text(
                          _capitalize(goal.status),
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tipo: ${_capitalize(goal.type)}',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress > 1 ? 1 : progress,
                backgroundColor: AppColors.greyLight,
                color: goal.status == 'atingida'
                    ? AppColors.statusAtingido
                    : AppColors.primary,
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.currentValue.toStringAsFixed(2)} $unit',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${goal.targetValue.toStringAsFixed(2)} $unit',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Início: ${_formatDate(goal.startDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.event_available,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Término: ${_formatDate(goal.endDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (goal.status == 'atingida' && goal.achievedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 16,
                      color: AppColors.statusAtingido,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Atingida em: ${_formatDate(goal.achievedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.statusAtingido,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _getUnitDisplay(String unit) {
    switch (unit) {
      case 'kg':
        return 'kg';
      case 'unidade':
        return 'un';
      case 'litro':
        return 'L';
      case 'saca':
        return 'sc';
      case 'caixa':
        return 'cx';
      case 'reais':
        return 'R\$';
      default:
        return unit;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planejada':
        return AppColors.statusPlanejado2;
      case 'ativa':
        return AppColors.statusAtivo;
      case 'atingida':
        return AppColors.statusAtingido;
      case 'cancelada':
        return AppColors.statusNaoAtingido;
      case 'pendente':
        return AppColors.statusNaoAtingido;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusEmoji(String status) {
    switch (status) {
      case 'planejada':
        return '📅';
      case 'ativa':
        return '📈';
      case 'atingida':
        return '✅';
      case 'cancelada':
        return '❌';
      case 'pendente':
        return '⌛';
      default:
        return '🏷';
    }
  }
}
