import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'components/user_header_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Mês';
  final List<String> _periods = ['Dia', 'Semana', 'Mês', 'Ano'];

  // Mock de produtos
  final List<Map<String, dynamic>> _products = [
    {'name': 'Tomate', 'profit': 12000.0},
    {'name': 'Alface', 'profit': 9500.0},
    {'name': 'Cenoura', 'profit': 8700.0},
    {'name': 'Batata', 'profit': 6500.0},
    {'name': 'Milho', 'profit': 4300.0},
  ];

  // Mock de indicadores
  final double _totalSales = 42000.0;
  final double _totalProfit = 32000.0;
  final int _orders = 150;
  final double _growth = 0.12; // 12% crescimento

  // Mock para comparação entre períodos
  final Map<String, double> _profitComparison = {
    'Anterior': 28000.0,
    'Atual': 32000.0,
  };

  @override
  Widget build(BuildContext context) {
    _products.sort((a, b) => b['profit'].compareTo(a['profit']));
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard de Vendas')),
      body: Padding(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _selectedPeriod,
                    items: _periods
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
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
                    'Produtos por Lucro',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-product');
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(product['name']),
                    trailing: Text(
                      'R\$ ${product['profit'].toStringAsFixed(2)}',
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Lucro por Produto (Gráfico)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    maxY: _products.first['profit'] * 1.2,
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
                            if (idx < 0 || idx >= _products.length)
                              return const SizedBox.shrink();
                            return Text(_products[idx]['name']);
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
                    barGroups: List.generate(_products.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: _products[i]['profit'],
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
