import 'package:fiap_farms/domain/entities/goals.dart';
import 'package:fiap_farms/presentation/controllers/goals_controller.dart';
import 'package:fiap_farms/routes.dart';
import 'package:fiap_farms/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalDetailsScreen extends StatelessWidget {
  final Goal goal;
  final GoalController controller;

  const GoalDetailsScreen({
    super.key,
    required this.goal,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(goal.status);
    final progress = goal.currentValue / goal.targetValue;
    final unit = _getUnitDisplay(goal.targetUnit);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Meta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () =>
                Navigator.pushNamed(context, Routes.goalsDashboard),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              margin: EdgeInsets.zero,
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
                              fontSize: 20,
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
                                  fontSize: 14,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Tipo:', _capitalize(goal.type)),
                    const SizedBox(height: 8),
                    _buildInfoRow('Unidade:', _capitalize(goal.targetUnit)),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Meta:',
                      _capitalize(goal.targetValue.toString()),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress > 1 ? 1 : progress,
                      backgroundColor: AppColors.greyLight,
                      color: goal.status == 'atingida'
                          ? AppColors.statusAtingido
                          : AppColors.primary,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progresso: ${goal.currentValue.toStringAsFixed(2)} $unit',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Meta: ${goal.targetValue.toStringAsFixed(2)} $unit',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Datas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDateRow(
                      icon: Icons.calendar_today,
                      label: 'Início:',
                      date: goal.startDate,
                    ),
                    const SizedBox(height: 8),
                    _buildDateRow(
                      icon: Icons.event_available,
                      label: 'Término:',
                      date: goal.endDate,
                    ),
                    if (goal.status == 'atingida' &&
                        goal.achievedAt != null) ...[
                      const SizedBox(height: 8),
                      _buildDateRow(
                        icon: Icons.celebration,
                        label: 'Atingida em:',
                        date: goal.achievedAt!,
                        color: AppColors.statusAtingido,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (goal.name.isNotEmpty)
              Card(
                elevation: 4,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Descrição',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(goal.name),
                    ],
                  ),
                ),
              ),
            // Botão de cancelamento adicionado no final da página
            if (goal.status != 'cancelada' && goal.status != 'atingida')
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showCancelConfirmationDialog(context),
                    child: const Text(
                      'Cancelar Meta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildDateRow({
    required IconData icon,
    required String label,
    required DateTime date,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatDate(date),
          style: TextStyle(
            fontSize: 14,
            color: color ?? AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _showCancelConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Meta'),
          content: const Text('Tem certeza que deseja cancelar esta meta?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _cancelGoal(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelGoal(BuildContext context) async {
    try {
      final canceledGoal = goal.copyWith(status: 'cancelada');
      await controller.updateGoal(canceledGoal);
      if (context.mounted) {
        Navigator.pushNamed(context, Routes.goalsDashboard);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar meta: ${e.toString()}')),
        );
      }
    }
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
        return '⏳';
      default:
        return '🏷';
    }
  }
}
