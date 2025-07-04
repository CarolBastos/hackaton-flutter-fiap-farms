import '../entities/production_batch.dart';
import '../repositories/production_repository.dart';

class CreateProductionBatchUseCase {
  final ProductionRepository repository;

  CreateProductionBatchUseCase(this.repository);

  Future<ProductionBatch> execute(ProductionBatch batch) {
    if (batch.productId.isEmpty) {
      throw Exception('ID do produto é obrigatório');
    }
    if (batch.productName.isEmpty) {
      throw Exception('Nome do produto é obrigatório');
    }
    if (batch.estimatedQuantity <= 0) {
      throw Exception('Quantidade estimada deve ser maior que zero');
    }
    if (batch.startDate.isAfter(batch.estimatedEndDate)) {
      throw Exception('Data de início deve ser anterior à data de colheita');
    }

    return repository.createProductionBatch(batch);
  }
}

class GetProductionBatchesUseCase {
  final ProductionRepository repository;

  GetProductionBatchesUseCase(this.repository);

  Future<List<ProductionBatch>> execute() {
    return repository.getProductionBatches();
  }
}

class GetProductionBatchesByStatusUseCase {
  final ProductionRepository repository;

  GetProductionBatchesByStatusUseCase(this.repository);

  Future<List<ProductionBatch>> execute(String status) {
    if (status.isEmpty) {
      throw Exception('Status é obrigatório');
    }

    return repository.getProductionBatchesByStatus(status);
  }
}

class UpdateProductionStatusUseCase {
  final ProductionRepository repository;

  UpdateProductionStatusUseCase(this.repository);

  Future<void> execute(String id, String status) {
    if (id.isEmpty) {
      throw Exception('ID do lote é obrigatório');
    }
    if (status.isEmpty) {
      throw Exception('Status é obrigatório');
    }

    return repository.updateProductionStatus(id, status);
  }
}
