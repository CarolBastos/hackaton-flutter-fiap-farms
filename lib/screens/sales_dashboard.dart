import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'components/user_header_widget.dart';
import 'components/menu_drawer.dart';
import 'components/custom_app_bar.dart';
import '../utils/app_colors.dart';
import '../routes.dart';
import '../presentation/controllers/product_controller.dart';
import '../presentation/controllers/sales_controller.dart';
import '../presentation/controllers/inventory_controller.dart';
import '../domain/entities/product.dart';
import '../domain/entities/sales_record.dart';
import '../domain/entities/inventory_item.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  String _selectedPeriod = 'Mês';
  final List<String> _periods = ['Dia', 'Semana', 'Mês', 'Ano'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false).loadProducts();
      Provider.of<SalesController>(context, listen: false).loadSalesRecords();
      Provider.of<InventoryController>(
        context,
        listen: false,
      ).loadInventoryItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardAppBar(title: 'Dashboard de Vendas'),
      drawer: MenuDrawer(currentRoute: Routes.dashboard),
      body: Consumer3<ProductController, SalesController, InventoryController>(
        builder: (context, productController, salesController, inventoryController, child) {
          if (productController.isLoading ||
              salesController.isLoading ||
              inventoryController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Calcular indicadores reais
          final totalSales = salesController.salesRecords.fold<double>(
            0.0,
            (sum, sale) => sum + sale.totalSaleAmount,
          );

          final totalProfit = salesController.salesRecords.fold<double>(
            0.0,
            (sum, sale) => sum + sale.calculatedProfit,
          );

          final orders = salesController.salesRecords.length;

          // Calcular crescimento (comparar com período anterior)
          final now = DateTime.now();
          final currentPeriodSales = salesController.salesRecords
              .where((sale) => _isInPeriod(sale.saleDate, _selectedPeriod, now))
              .fold<double>(0.0, (sum, sale) => sum + sale.totalSaleAmount);

          final previousPeriodSales = salesController.salesRecords
              .where(
                (sale) =>
                    _isInPreviousPeriod(sale.saleDate, _selectedPeriod, now),
              )
              .fold<double>(0.0, (sum, sale) => sum + sale.totalSaleAmount);

          final growth = previousPeriodSales > 0
              ? (currentPeriodSales - previousPeriodSales) / previousPeriodSales
              : 0.0;

          // Criar lista de produtos com dados reais de lucro
          final productsWithProfit = productController.products.map((product) {
            final productSales = salesController.salesRecords
                .where((sale) => sale.productId == product.id)
                .toList();

            final totalProductProfit = productSales.fold<double>(
              0.0,
              (sum, sale) => sum + sale.calculatedProfit,
            );

            return {'product': product, 'profit': totalProductProfit};
          }).toList();

          // Ordenar por lucro
          productsWithProfit.sort(
            (a, b) => (b['profit'] as double).compareTo(a['profit'] as double),
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UserHeader(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Período:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedPeriod,
                        items: _periods
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPeriod = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Indicadores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _IndicatorCard(
                        title: 'Vendas',
                        value: 'R\$ ${totalSales.toStringAsFixed(2)}',
                        icon: Icons.shopping_cart,
                      ),
                      _IndicatorCard(
                        title: 'Lucro',
                        value: 'R\$ ${totalProfit.toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                      ),
                      _IndicatorCard(
                        title: 'Pedidos',
                        value: '$orders',
                        icon: Icons.receipt_long,
                      ),
                      _IndicatorCard(
                        title: 'Crescimento',
                        value: '${(growth * 100).toStringAsFixed(1)}%',
                        icon: Icons.trending_up,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Produtos Cadastrados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.addProduct);
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Cadastrar Produto'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (productsWithProfit.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Nenhum produto cadastrado ainda. Clique em "Cadastrar Produto" para começar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productsWithProfit.length,
                      itemBuilder: (context, index) {
                        final productData = productsWithProfit[index];
                        final product = productData['product'] as Product;
                        final profit = productData['profit'] as double;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppColors.textWhite,
                              ),
                            ),
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            '${product.category} • ${product.unitOfMeasure}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'R\$ ${profit.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                'Custo: R\$ ${product.estimatedCostPerUnit.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  if (productsWithProfit.isNotEmpty) ...[
                    const Text(
                      'Lucro por Produto (Gráfico)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceBetween,
                          maxY:
                              (productsWithProfit.first['profit'] as double) *
                              1.2,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value % 5000 == 0) {
                                    return Text('R\$${value ~/ 1000}k');
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < 0 ||
                                      idx >= productsWithProfit.length)
                                    return const SizedBox.shrink();
                                  final product =
                                      productsWithProfit[idx]['product']
                                          as Product;
                                  return Text(product.name);
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(productsWithProfit.length, (
                            i,
                          ) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY:
                                      productsWithProfit[i]['profit'] as double,
                                  color: AppColors.success,
                                  width: 22,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Comparação de Lucro',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ComparisonCard(
                        label: 'Período Anterior',
                        value: previousPeriodSales,
                      ),
                      _ComparisonCard(
                        label: 'Período Atual',
                        value: currentPeriodSales,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Análise Detalhada',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    previousPeriodSales > 0
                        ? 'O lucro ${growth >= 0 ? 'aumentou' : 'diminuiu'} ${(growth * 100).abs().toStringAsFixed(1)}% em relação ao período anterior.'
                        : 'Não há dados suficientes para comparação.',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isInPeriod(DateTime date, String period, DateTime now) {
    switch (period) {
      case 'Dia':
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case 'Semana':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            date.isBefore(weekEnd.add(const Duration(days: 1)));
      case 'Mês':
        return date.year == now.year && date.month == now.month;
      case 'Ano':
        return date.year == now.year;
      default:
        return false;
    }
  }

  bool _isInPreviousPeriod(DateTime date, String period, DateTime now) {
    switch (period) {
      case 'Dia':
        final yesterday = now.subtract(const Duration(days: 1));
        return date.year == yesterday.year &&
            date.month == yesterday.month &&
            date.day == yesterday.day;
      case 'Semana':
        final lastWeekStart = now.subtract(Duration(days: now.weekday + 6));
        final lastWeekEnd = lastWeekStart.add(const Duration(days: 6));
        return date.isAfter(lastWeekStart.subtract(const Duration(days: 1))) &&
            date.isBefore(lastWeekEnd.add(const Duration(days: 1)));
      case 'Mês':
        final lastMonth = DateTime(now.year, now.month - 1);
        return date.year == lastMonth.year && date.month == lastMonth.month;
      case 'Ano':
        return date.year == now.year - 1;
      default:
        return false;
    }
  }
}

class _IndicatorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _IndicatorCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: AppColors.success),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final String label;
  final double value;
  const _ComparisonCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'R\$ ${value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
