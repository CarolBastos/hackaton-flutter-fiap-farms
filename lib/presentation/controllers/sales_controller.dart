import 'package:flutter/material.dart';
import '../../domain/entities/sales_record.dart';
import '../../domain/usecases/sales_usecases.dart';
import '../../domain/usecases/goals_usecases.dart';

class SalesController extends ChangeNotifier {
  final CreateSalesRecordUseCase _createSalesRecordUseCase;
  final GetSalesRecordsUseCase _getSalesRecordsUseCase;
  final GetSalesRecordsByDateRangeUseCase _getSalesRecordsByDateRangeUseCase;
  final UpdateSalesRecordUseCase _updateSalesRecordUseCase;
  final DeleteSalesRecordUseCase _deleteSalesRecordUseCase;
  final GetGoalsByStatusUseCase _getGoalsByStatusUseCase;
  final UpdateGoalProgressUseCase _updateGoalProgressUseCase;
  final CompleteGoalUseCase _completeGoalUseCase;
  final BuildContext context;

  SalesController({
    required this.context,
    required CreateSalesRecordUseCase createSalesRecordUseCase,
    required GetSalesRecordsUseCase getSalesRecordsUseCase,
    required GetSalesRecordsByDateRangeUseCase
    getSalesRecordsByDateRangeUseCase,
    required UpdateSalesRecordUseCase updateSalesRecordUseCase,
    required DeleteSalesRecordUseCase deleteSalesRecordUseCase,
    required GetGoalsByStatusUseCase getGoalsByStatusUseCase,
    required UpdateGoalProgressUseCase updateGoalProgressUseCase,
    required CompleteGoalUseCase completeGoalUseCase,
  }) : _createSalesRecordUseCase = createSalesRecordUseCase,
       _getSalesRecordsUseCase = getSalesRecordsUseCase,
       _getSalesRecordsByDateRangeUseCase = getSalesRecordsByDateRangeUseCase,
       _updateSalesRecordUseCase = updateSalesRecordUseCase,
       _deleteSalesRecordUseCase = deleteSalesRecordUseCase,
       _getGoalsByStatusUseCase = getGoalsByStatusUseCase,
       _updateGoalProgressUseCase = updateGoalProgressUseCase,
       _completeGoalUseCase = completeGoalUseCase;

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
      final newRecord = await _createSalesRecordUseCase.execute(salesRecord);
      _salesRecords.insert(0, newRecord);
      print('Criando venda: ${salesRecord.quantitySold}');
      await _updateGoalProgress(newRecord.quantitySold, 'vendas');
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _updateGoalProgress(double increment, String type) async {
    print(
      'Iniciando atualização de metas ativas do tipo: $type com incremento: $increment',
    );

    final activeGoals = await _getGoalsByStatusUseCase.execute('ativa');
    print('Metas ativas encontradas: ${activeGoals.length}');

    for (final goal in activeGoals.where((g) => g.type == type)) {
      final newValue = goal.currentValue + increment;
      print(
        'Meta: ${goal.name} (ID: ${goal.id}) | Valor atual: ${goal.currentValue}, Novo valor: $newValue',
      );

      await _updateGoalProgressUseCase.execute(goal.id!, newValue);
      notifyListeners();

      if (newValue >= goal.targetValue) {
        print('Meta "${goal.name}" atingida! Marcando como concluída.');
        await _completeGoalUseCase.execute(goal.id!);
        _showGoalAchievedPopup(goal.name);
      }
    }
  }

  void _showGoalAchievedPopup(String goalName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Meta Atingida!'),
          content: Text('A meta "$goalName" foi atingida.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    });
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
