import '../entities/sales_data.dart';
import '../repositories/sales_repository.dart';

class GetSalesDataUseCase {
  final SalesRepository repository;

  GetSalesDataUseCase(this.repository);

  Future<SalesData> execute(String period) {
    if (period.isEmpty) {
      throw Exception('Período é obrigatório');
    }

    return repository.getSalesData(period);
  }
}

class GetTopProductsUseCase {
  final SalesRepository repository;

  GetTopProductsUseCase(this.repository);

  Future<List<ProductData>> execute(String period) {
    if (period.isEmpty) {
      throw Exception('Período é obrigatório');
    }

    return repository.getTopProducts(period);
  }
}
