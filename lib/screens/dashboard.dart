import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'components/user_header_widget.dart';
import 'components/app_drawer.dart';
import '../utils/app_colors.dart';
import '../routes.dart';
import '../presentation/controllers/product_controller.dart';
import '../domain/entities/product.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Mês';
  final List<String> _periods = ['Dia', 'Semana', 'Mês', 'Ano'];

  // Mock de indicadores (mantidos temporariamente)
  final double _totalSales = 42000.0;
  final double _totalProfit = 32000.0;
  final int _orders = 150;
  final double _growth = 0.12; // 12% crescimento

  // Mock para comparação entre períodos (mantidos temporariamente)
  final Map<String, double> _profitComparison = {
    'Anterior': 28000.0,
    'Atual': 32000.0,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Vendas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(currentRoute: Routes.dashboard),
      body: Consumer<ProductController>(
        builder: (context, productController, child) {
          if (productController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Criar lista de produtos com dados simulados de lucro para o gráfico
          final productsWithProfit = productController.products.map((product) {
            // Simular lucro baseado no custo estimado (para demonstração)
            final simulatedProfit =
                product.estimatedCostPerUnit * 2.5; // 150% de margem
            return {'product': product, 'profit': simulatedProfit};
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
                        value: 'R\$ ${_totalSales.toStringAsFixed(2)}',
                        icon: Icons.shopping_cart,
                      ),
                      _IndicatorCard(
                        title: 'Lucro',
                        value: 'R\$ ${_totalProfit.toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                      ),
                      _IndicatorCard(
                        title: 'Pedidos',
                        value: '$_orders',
                        icon: Icons.receipt_long,
                      ),
                      _IndicatorCard(
                        title: 'Crescimento',
                        value: '${(_growth * 100).toStringAsFixed(1)}%',
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
                          style: TextStyle(fontSize: 16, color: Colors.grey),
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
                              style: const TextStyle(color: Colors.white),
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
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Custo: R\$ ${product.estimatedCostPerUnit.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
                                  color: Colors.green,
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
                        value: _profitComparison['Anterior']!,
                      ),
                      _ComparisonCard(
                        label: 'Período Atual',
                        value: _profitComparison['Atual']!,
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
                    'O lucro aumentou ${(100 * (_profitComparison['Atual']! - _profitComparison['Anterior']!) / _profitComparison['Anterior']!).toStringAsFixed(1)}% em relação ao período anterior.',
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
            Icon(icon, size: 28, color: Colors.green),
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
