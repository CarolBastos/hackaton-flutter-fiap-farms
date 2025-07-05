import '../entities/sales_data.dart';
import '../entities/sales_record.dart';
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

// Novos use cases para SalesRecord
class CreateSalesRecordUseCase {
  final SalesRepository repository;

  CreateSalesRecordUseCase(this.repository);

  Future<SalesRecord> execute(SalesRecord salesRecord) {
    if (salesRecord.productId.isEmpty) {
      throw Exception('ID do produto é obrigatório');
    }
    if (salesRecord.quantitySold <= 0) {
      throw Exception('Quantidade vendida deve ser maior que zero');
    }
    if (salesRecord.salePricePerUnit <= 0) {
      throw Exception('Preço de venda deve ser maior que zero');
    }

    return repository.createSalesRecord(salesRecord);
  }
}

class GetSalesRecordsUseCase {
  final SalesRepository repository;

  GetSalesRecordsUseCase(this.repository);

  Future<List<SalesRecord>> execute() {
    return repository.getSalesRecords();
  }
}

class GetSalesRecordsByDateRangeUseCase {
  final SalesRepository repository;

  GetSalesRecordsByDateRangeUseCase(this.repository);

  Future<List<SalesRecord>> execute(DateTime startDate, DateTime endDate) {
    if (startDate.isAfter(endDate)) {
      throw Exception('Data inicial deve ser anterior à data final');
    }

    return repository.getSalesRecordsByDateRange(startDate, endDate);
  }
}

class UpdateSalesRecordUseCase {
  final SalesRepository repository;

  UpdateSalesRecordUseCase(this.repository);

  Future<void> execute(SalesRecord salesRecord) {
    if (salesRecord.id == null) {
      throw Exception('ID do registro de venda é obrigatório');
    }

    return repository.updateSalesRecord(salesRecord);
  }
}

class DeleteSalesRecordUseCase {
  final SalesRepository repository;

  DeleteSalesRecordUseCase(this.repository);

  Future<void> execute(String id) {
    if (id.isEmpty) {
      throw Exception('ID do registro de venda é obrigatório');
    }

    return repository.deleteSalesRecord(id);
  }
}
