import '../entities/production_batch.dart';

abstract class ProductionRepository {
  Future<ProductionBatch> createProductionBatch(ProductionBatch batch);
  Future<List<ProductionBatch>> getProductionBatches();
  Future<List<ProductionBatch>> getProductionBatchesByStatus(String status);
  Future<ProductionBatch?> getProductionBatchById(String id);
  Future<void> updateProductionBatch(ProductionBatch batch);
  Future<void> updateProductionStatus(String id, String status);
  Future<void> deleteProductionBatch(String id);
}
