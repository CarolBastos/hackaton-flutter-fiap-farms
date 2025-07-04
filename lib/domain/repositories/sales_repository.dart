import '../entities/sales_data.dart';

abstract class SalesRepository {
  Future<SalesData> getSalesData(String period);
  Future<List<ProductData>> getTopProducts(String period);
}
