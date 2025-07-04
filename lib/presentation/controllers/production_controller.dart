import 'package:flutter/material.dart';
import '../../domain/entities/production_batch.dart';
import '../../domain/usecases/production_usecases.dart';

class ProductionController extends ChangeNotifier {
  final CreateProductionBatchUseCase _createProductionBatchUseCase;
  final GetProductionBatchesUseCase _getProductionBatchesUseCase;
  final GetProductionBatchesByStatusUseCase
  _getProductionBatchesByStatusUseCase;
  final UpdateProductionStatusUseCase _updateProductionStatusUseCase;

  ProductionController({
    required CreateProductionBatchUseCase createProductionBatchUseCase,
    required GetProductionBatchesUseCase getProductionBatchesUseCase,
    required GetProductionBatchesByStatusUseCase
    getProductionBatchesByStatusUseCase,
    required UpdateProductionStatusUseCase updateProductionStatusUseCase,
  }) : _createProductionBatchUseCase = createProductionBatchUseCase,
       _getProductionBatchesUseCase = getProductionBatchesUseCase,
       _getProductionBatchesByStatusUseCase =
           getProductionBatchesByStatusUseCase,
       _updateProductionStatusUseCase = updateProductionStatusUseCase;

  List<ProductionBatch> _productionBatches = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedStatusFilter = '';

  List<ProductionBatch> get productionBatches => _productionBatches;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedStatusFilter => _selectedStatusFilter;

  // Filtros por status
  List<ProductionBatch> get batchesByStatus {
    if (_selectedStatusFilter.isEmpty) {
      return _productionBatches;
    }
    return _productionBatches
        .where((batch) => batch.status.name == _selectedStatusFilter)
        .toList();
  }

  // Contadores por status
  int get planejadoCount => _productionBatches
      .where((batch) => batch.status == ProductionStatus.planejado)
      .length;

  int get aguardandoCount => _productionBatches
      .where((batch) => batch.status == ProductionStatus.aguardando_inicio)
      .length;

  int get emProducaoCount => _productionBatches
      .where((batch) => batch.status == ProductionStatus.em_producao)
      .length;

  int get colhidoCount => _productionBatches
      .where((batch) => batch.status == ProductionStatus.colhido)
      .length;

  Future<void> createProductionBatch(ProductionBatch batch) async {
    _setLoading(true);
    _clearError();

    try {
      final newBatch = await _createProductionBatchUseCase.execute(batch);
      _productionBatches.insert(0, newBatch);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProductionBatches() async {
    _setLoading(true);
    _clearError();

    try {
      _productionBatches = await _getProductionBatchesUseCase.execute();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProductionBatchesByStatus(String status) async {
    _setLoading(true);
    _clearError();

    try {
      _productionBatches = await _getProductionBatchesByStatusUseCase.execute(
        status,
      );
      _selectedStatusFilter = status;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProductionStatus(String id, String status) async {
    _setLoading(true);
    _clearError();

    try {
      await _updateProductionStatusUseCase.execute(id, status);

      // Atualiza o status localmente
      final index = _productionBatches.indexWhere((batch) => batch.id == id);
      if (index != -1) {
        final updatedBatch = _productionBatches[index].copyWith(
          status: _parseStatus(status),
          lastUpdatedAt: DateTime.now(),
        );
        _productionBatches[index] = updatedBatch;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void clearStatusFilter() {
    _selectedStatusFilter = '';
    notifyListeners();
  }

  ProductionStatus _parseStatus(String status) {
    switch (status) {
      case 'planejado':
        return ProductionStatus.planejado;
      case 'aguardando_inicio':
        return ProductionStatus.aguardando_inicio;
      case 'em_producao':
        return ProductionStatus.em_producao;
      case 'colhido':
        return ProductionStatus.colhido;
      case 'cancelado':
        return ProductionStatus.cancelado;
      default:
        return ProductionStatus.planejado;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
