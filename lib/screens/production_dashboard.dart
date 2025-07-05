import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/entities/production_batch.dart';
import '../presentation/controllers/production_controller.dart';
import '../utils/app_colors.dart';
import '../routes.dart';
import 'components/app_drawer.dart';

class ProductionDashboard extends StatefulWidget {
  const ProductionDashboard({super.key});

  @override
  State<ProductionDashboard> createState() => _ProductionDashboardState();
}

class _ProductionDashboardState extends State<ProductionDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductionController>(
        context,
        listen: false,
      ).loadProductionBatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Produção'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, Routes.addProduction);
            },
            tooltip: 'Adicionar Lote',
          ),
        ],
      ),
      drawer: AppDrawer(currentRoute: Routes.productionDashboard),
      body: Consumer<ProductionController>(
        builder: (context, productionController, child) {
          if (productionController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Cards de Status
                _buildStatusCards(productionController),
                const SizedBox(height: 24),

                // Filtros
                _buildStatusFilters(productionController),
                const SizedBox(height: 16),

                // Lista de Lotes
                _buildProductionList(productionController),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCards(ProductionController controller) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatusCard(
          title: 'Planejado',
          count: controller.planejadoCount,
          icon: Icons.schedule,
          color: Colors.blue,
          emoji: '📋',
        ),
        _StatusCard(
          title: 'Aguardando',
          count: controller.aguardandoCount,
          icon: Icons.pending,
          color: Colors.orange,
          emoji: '🟡',
        ),
        _StatusCard(
          title: 'Em Produção',
          count: controller.emProducaoCount,
          icon: Icons.agriculture,
          color: Colors.green,
          emoji: '🌱',
        ),
        _StatusCard(
          title: 'Colhido',
          count: controller.colhidoCount,
          icon: Icons.check_circle,
          color: Colors.purple,
          emoji: '🟢',
        ),
      ],
    );
  }

  Widget _buildStatusFilters(ProductionController controller) {
    final statuses = [
      {'name': 'Todos', 'value': ''},
      {'name': 'Planejado', 'value': 'planejado'},
      {'name': 'Aguardando', 'value': 'aguardando_inicio'},
      {'name': 'Em Produção', 'value': 'em_producao'},
      {'name': 'Colhido', 'value': 'colhido'},
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
                  onSelected: (selected) {
                    if (selected) {
                      if (status['value']!.isEmpty) {
                        controller.clearStatusFilter();
                        controller.loadProductionBatches();
                      } else {
                        controller.loadProductionBatchesByStatus(
                          status['value']!,
                        );
                      }
                    }
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductionList(ProductionController controller) {
    final batches = controller.batchesByStatus;

    if (batches.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum lote de produção encontrado',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lotes de Produção (${batches.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: batches.length,
          itemBuilder: (context, index) {
            final batch = batches[index];
            return _ProductionBatchCard(
              batch: batch,
              onStatusChanged: (newStatus) {
                controller.updateProductionStatus(batch.id!, newStatus);
              },
            );
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

class _ProductionBatchCard extends StatelessWidget {
  final ProductionBatch batch;
  final Function(String) onStatusChanged;

  const _ProductionBatchCard({
    required this.batch,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                    batch.productName,
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
                    color: _getStatusColor(batch.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(batch.statusEmoji),
                      const SizedBox(width: 4),
                      Text(
                        batch.statusString,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(batch.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Início: ${_formatDate(batch.startDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.event, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Colheita: ${_formatDate(batch.estimatedEndDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.scale, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Estimado: ${batch.estimatedQuantity.toStringAsFixed(1)} kg',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (batch.actualQuantity != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    'Real: ${batch.actualQuantity!.toStringAsFixed(1)} kg',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
            if (batch.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Notas: ${batch.notes}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 12),
            _buildStatusButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButtons() {
    final currentStatus = batch.status;
    final nextStatuses = _getNextStatuses(currentStatus);

    if (nextStatuses.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      children: nextStatuses.map((status) {
        return ElevatedButton(
          onPressed: () => onStatusChanged(status.name),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getStatusColor(status),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            textStyle: const TextStyle(fontSize: 12),
          ),
          child: Text('Marcar como ${_statusToString(status)}'),
        );
      }).toList(),
    );
  }

  String _statusToString(ProductionStatus status) {
    switch (status) {
      case ProductionStatus.planejado:
        return 'Planejado';
      case ProductionStatus.aguardando_inicio:
        return 'Aguardando Início';
      case ProductionStatus.em_producao:
        return 'Em Produção';
      case ProductionStatus.colhido:
        return 'Colhido';
      case ProductionStatus.cancelado:
        return 'Cancelado';
    }
  }

  List<ProductionStatus> _getNextStatuses(ProductionStatus current) {
    switch (current) {
      case ProductionStatus.planejado:
        return [ProductionStatus.aguardando_inicio];
      case ProductionStatus.aguardando_inicio:
        return [ProductionStatus.em_producao];
      case ProductionStatus.em_producao:
        return [ProductionStatus.colhido];
      case ProductionStatus.colhido:
        return [];
      case ProductionStatus.cancelado:
        return [];
    }
  }

  Color _getStatusColor(ProductionStatus status) {
    switch (status) {
      case ProductionStatus.planejado:
        return Colors.blue;
      case ProductionStatus.aguardando_inicio:
        return Colors.orange;
      case ProductionStatus.em_producao:
        return Colors.green;
      case ProductionStatus.colhido:
        return Colors.purple;
      case ProductionStatus.cancelado:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
