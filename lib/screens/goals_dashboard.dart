import 'package:fiap_farms/domain/entities/goals.dart';
import 'package:fiap_farms/presentation/controllers/goals_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GoalController>(context, listen: false).loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardAppBar(title: 'Dashboard de Metas'),
      drawer: MenuDrawer(currentRoute: Routes.goalsDashboard),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addGoal);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<GoalController>(
        builder: (context, goalController, child) {
          if (goalController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (goalController.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                'Erro ao carregar metas: ${goalController.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Cards de Status
                _buildStatusCards(goalController),
                const SizedBox(height: 24),

                // Filtros
                _buildStatusFilters(goalController),
                const SizedBox(height: 16),

                // Lista de Metas
                _buildGoalsList(goalController),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCards(GoalController controller) {
    final now = DateTime.now();
    final stats = controller.getGoalStatistics(now);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatusCard(
          title: 'Planejadas',
          count: stats.plannedCount,
          icon: Icons.schedule,
          color: AppColors.statusPlanejado2,
          emoji: '📅',
        ),
        _StatusCard(
          title: 'Ativas',
          count: stats.activeCount,
          icon: Icons.trending_up,
          color: AppColors.statusAtivo,
          emoji: '📈',
        ),
        _StatusCard(
          title: 'Atingidas',
          count: stats.completedCount,
          icon: Icons.check_circle,
          color: AppColors.statusAtingido,
          emoji: '✅',
        ),
        _StatusCard(
          title: 'Não Atingidas',
          count: stats.failedCount,
          icon: Icons.warning,
          color: AppColors.statusNaoAtingido,
          emoji: '❌',
        ),
      ],
    );
  }

  Widget _buildStatusFilters(GoalController controller) {
    final statuses = [
      {'name': 'Todos', 'value': ''},
      {'name': 'Planejadas', 'value': 'planned'},
      {'name': 'Ativas', 'value': 'active'},
      {'name': 'Atingidas', 'value': 'completed'},
      {'name': 'Não Atingidas', 'value': 'failed'},
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
                child: FilterChip(
                  label: Text(status['name']!),
                  selected: isSelected,
                  onSelected: (selected) async {
                    if (selected) {
                      if (status['value']!.isEmpty) {
                        await controller.clearStatusFilter();
                      } else {
                        await controller.loadGoalsByStatus(status['value']!);
                      }
                    }
                  },
                  backgroundColor: AppColors.greyLight,
                  selectedColor: AppColors.primary.withOpacity(0.2),
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
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
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
            return _GoalCard(goal: goal);
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

  const _StatusCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = _getGoalStatus(goal, now);
    final statusColor = _getStatusColor(status);
    final progress = goal.currentValue / goal.targetValue;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                      Text(_getStatusEmoji(status)),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(status),
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
              goal.name,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress > 1 ? 1 : progress,
              backgroundColor: AppColors.greyLight,
              color: progress >= 1 
                  ? AppColors.statusAtingido
                  : AppColors.primary,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R\$ ${goal.currentValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'R\$ ${goal.targetValue.toStringAsFixed(2)}',
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
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  GoalStatus _getGoalStatus(Goal goal, DateTime now) {
    if (goal.currentValue >= goal.targetValue) {
      return GoalStatus.completed;
    }
    
    if (now.isBefore(goal.startDate)) {
      return GoalStatus.planned;
    }
    
    if (now.isAfter(goal.endDate)) {
      return GoalStatus.failed;
    }
    
    return GoalStatus.active;
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.planned:
        return AppColors.statusPlanejado2;
      case GoalStatus.active:
        return AppColors.statusAtivo;
      case GoalStatus.completed:
        return AppColors.statusAtingido;
      case GoalStatus.failed:
        return AppColors.statusNaoAtingido;
    }
  }

  String _getStatusEmoji(GoalStatus status) {
    switch (status) {
      case GoalStatus.planned:
        return '📅';
      case GoalStatus.active:
        return '📈';
      case GoalStatus.completed:
        return '✅';
      case GoalStatus.failed:
        return '❌';
    }
  }

  String _getStatusText(GoalStatus status) {
    switch (status) {
      case GoalStatus.planned:
        return 'Planejada';
      case GoalStatus.active:
        return 'Ativa';
      case GoalStatus.completed:
        return 'Atingida';
      case GoalStatus.failed:
        return 'Não Atingida';
    }
  }
}

enum GoalStatus {
  planned,
  active,
  completed,
  failed,
}