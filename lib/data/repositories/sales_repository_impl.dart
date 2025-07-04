import '../../domain/entities/sales_data.dart';
import '../../domain/repositories/sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  @override
  Future<SalesData> getSalesData(String period) async {
    // Simulando delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    // Dados mock baseados no período
    switch (period) {
      case 'Dia':
        return SalesData(
          totalSales: 1500.0,
          totalProfit: 1200.0,
          orders: 25,
          growth: 0.08,
          products: [
            ProductData(name: 'Tomate', profit: 400.0),
            ProductData(name: 'Alface', profit: 300.0),
            ProductData(name: 'Cenoura', profit: 250.0),
          ],
        );
      case 'Semana':
        return SalesData(
          totalSales: 8500.0,
          totalProfit: 6800.0,
          orders: 120,
          growth: 0.15,
          products: [
            ProductData(name: 'Tomate', profit: 2200.0),
            ProductData(name: 'Alface', profit: 1800.0),
            ProductData(name: 'Cenoura', profit: 1500.0),
          ],
        );
      case 'Mês':
        return SalesData(
          totalSales: 42000.0,
          totalProfit: 32000.0,
          orders: 150,
          growth: 0.12,
          products: [
            ProductData(name: 'Tomate', profit: 12000.0),
            ProductData(name: 'Alface', profit: 9500.0),
            ProductData(name: 'Cenoura', profit: 8700.0),
            ProductData(name: 'Batata', profit: 6500.0),
            ProductData(name: 'Milho', profit: 4300.0),
          ],
        );
      case 'Ano':
        return SalesData(
          totalSales: 480000.0,
          totalProfit: 360000.0,
          orders: 1800,
          growth: 0.25,
          products: [
            ProductData(name: 'Tomate', profit: 120000.0),
            ProductData(name: 'Alface', profit: 95000.0),
            ProductData(name: 'Cenoura', profit: 87000.0),
            ProductData(name: 'Batata', profit: 65000.0),
            ProductData(name: 'Milho', profit: 43000.0),
          ],
        );
      default:
        throw Exception('Período inválido');
    }
  }

  @override
  Future<List<ProductData>> getTopProducts(String period) async {
    final salesData = await getSalesData(period);
    return salesData.products;
  }
}
