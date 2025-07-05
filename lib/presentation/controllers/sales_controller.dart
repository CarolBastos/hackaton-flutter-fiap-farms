import 'package:flutter/material.dart';
import '../../domain/entities/sales_record.dart';
import '../../domain/usecases/sales_usecases.dart';

class SalesController extends ChangeNotifier {
  final CreateSalesRecordUseCase _createSalesRecordUseCase;
  final GetSalesRecordsUseCase _getSalesRecordsUseCase;
  final GetSalesRecordsByDateRangeUseCase _getSalesRecordsByDateRangeUseCase;
  final UpdateSalesRecordUseCase _updateSalesRecordUseCase;
  final DeleteSalesRecordUseCase _deleteSalesRecordUseCase;

  SalesController({
    required CreateSalesRecordUseCase createSalesRecordUseCase,
    required GetSalesRecordsUseCase getSalesRecordsUseCase,
    required GetSalesRecordsByDateRangeUseCase
    getSalesRecordsByDateRangeUseCase,
    required UpdateSalesRecordUseCase updateSalesRecordUseCase,
    required DeleteSalesRecordUseCase deleteSalesRecordUseCase,
  }) : _createSalesRecordUseCase = createSalesRecordUseCase,
       _getSalesRecordsUseCase = getSalesRecordsUseCase,
       _getSalesRecordsByDateRangeUseCase = getSalesRecordsByDateRangeUseCase,
       _updateSalesRecordUseCase = updateSalesRecordUseCase,
       _deleteSalesRecordUseCase = deleteSalesRecordUseCase;

  List<SalesRecord> _salesRecords = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<SalesRecord> get salesRecords => _salesRecords;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> createSalesRecord(SalesRecord salesRecord) async {
    _setLoading(true);
    _clearError();

    try {
      final newSalesRecord = await _createSalesRecordUseCase.execute(
        salesRecord,
      );
      _salesRecords.insert(0, newSalesRecord);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSalesRecords() async {
    _setLoading(true);
    _clearError();

    try {
      _salesRecords = await _getSalesRecordsUseCase.execute();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSalesRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      _salesRecords = await _getSalesRecordsByDateRangeUseCase.execute(
        startDate,
        endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSalesRecord(SalesRecord salesRecord) async {
    _setLoading(true);
    _clearError();

    try {
      await _updateSalesRecordUseCase.execute(salesRecord);
      final index = _salesRecords.indexWhere(
        (record) => record.id == salesRecord.id,
      );
      if (index != -1) {
        _salesRecords[index] = salesRecord;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteSalesRecord(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _deleteSalesRecordUseCase.execute(id);
      _salesRecords.removeWhere((record) => record.id == id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
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
