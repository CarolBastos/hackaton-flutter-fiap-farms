import '../entities/sales_data.dart';
import '../entities/sales_record.dart';

abstract class SalesRepository {
  Future<SalesData> getSalesData(String period);
  Future<List<ProductData>> getTopProducts(String period);
  Future<SalesRecord> createSalesRecord(SalesRecord salesRecord);
  Future<List<SalesRecord>> getSalesRecords();
  Future<List<SalesRecord>> getSalesRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<SalesRecord?> getSalesRecordById(String id);
  Future<void> updateSalesRecord(SalesRecord salesRecord);
  Future<void> deleteSalesRecord(String id);
}
