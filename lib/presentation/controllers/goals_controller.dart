import 'package:fiap_farms/domain/entities/goals.dart';
import 'package:fiap_farms/domain/usecases/goals_usecases.dart';
import 'package:flutter/material.dart';

class GoalStatistics {
  final int plannedCount;
  final int activeCount;
  final int completedCount;
  final int canceledCount;
  final int pendingCount;

  GoalStatistics({
    required this.plannedCount,
    required this.activeCount,
    required this.completedCount,
    required this.canceledCount,
    required this.pendingCount,
  });
}

class GoalController extends ChangeNotifier {
  final CreateGoalUseCase _createGoalUseCase;
  final GetGoalsUseCase _getGoalsUseCase;
  final GetGoalByIdUseCase _getGoalByIdUseCase;
  final UpdateGoalUseCase _updateGoalUseCase;
  final DeleteGoalUseCase _deleteGoalUseCase;
  final GetGoalsByTypeUseCase _getGoalsByTypeUseCase;
  final GetGoalsByStatusUseCase _getGoalsByStatusUseCase;
  final UpdateGoalProgressUseCase _updateGoalProgressUseCase;
  final CompleteGoalUseCase _completeGoalUseCase;

  GoalController({
    required CreateGoalUseCase createGoalUseCase,
    required GetGoalsUseCase getGoalsUseCase,
    required GetGoalByIdUseCase getGoalByIdUseCase,
    required UpdateGoalUseCase updateGoalUseCase,
    required DeleteGoalUseCase deleteGoalUseCase,
    required GetGoalsByTypeUseCase getGoalsByTypeUseCase,
    required GetGoalsByStatusUseCase getGoalsByStatusUseCase,
    required UpdateGoalProgressUseCase updateGoalProgressUseCase,
    required CompleteGoalUseCase completeGoalUseCase,
  }) : _createGoalUseCase = createGoalUseCase,
       _getGoalsUseCase = getGoalsUseCase,
       _getGoalByIdUseCase = getGoalByIdUseCase,
       _updateGoalUseCase = updateGoalUseCase,
       _deleteGoalUseCase = deleteGoalUseCase,
       _getGoalsByTypeUseCase = getGoalsByTypeUseCase,
       _getGoalsByStatusUseCase = getGoalsByStatusUseCase,
       _updateGoalProgressUseCase = updateGoalProgressUseCase,
       _completeGoalUseCase = completeGoalUseCase;

  List<Goal> _goals = [];
  List<Goal> _filteredGoals = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedStatusFilter = '';
  String _selectedTypeFilter = '';

  List<Goal> get goals => _goals;
  List<Goal> get filteredGoals => _filteredGoals;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedStatusFilter => _selectedStatusFilter;
  String get selectedTypeFilter => _selectedTypeFilter;

  Future<void> initializeGoalsIfNeeded() async {
    _setLoading(true);
    _clearError();
    try {
      await checkAndUpdateExpiredGoals();
      _goals = await _getGoalsUseCase.execute();
      if (_selectedStatusFilter.isNotEmpty) {
        await loadGoalsByStatus(_selectedStatusFilter);
      } else {
        _filteredGoals = List.from(_goals);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reloadGoals() async {
    await loadGoals();
    await loadGoalsByStatus(_selectedStatusFilter);
  }

  Future<void> createGoal(Goal goal) async {
    _setLoading(true);
    _clearError();
    try {
      final newGoal = await _createGoalUseCase.execute(goal);
      _goals.insert(0, newGoal);
      _filteredGoals = List.from(_goals);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGoals() async {
    _setLoading(true);
    _clearError();
    try {
      _goals = await _getGoalsUseCase.execute();
      _filteredGoals = List.from(_goals);
      _selectedStatusFilter = '';
      _selectedTypeFilter = '';
      await checkAndUpdateExpiredGoals();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGoalsByStatus(String status) async {
    _setLoading(true);
    _clearError();
    try {
      if (status.isEmpty) {
        _filteredGoals = List.from(_goals);
      } else {
        _filteredGoals = _goals.where((goal) => goal.status == status).toList();
      }
      _selectedStatusFilter = status;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearStatusFilter() async {
    _selectedStatusFilter = '';
    _filteredGoals = List.from(_goals);
    notifyListeners();
  }

  GoalStatistics getGoalStatistics(DateTime now) {
    int planned = 0;
    int active = 0;
    int completed = 0;
    int canceled = 0;
    int pending = 0;

    for (final goal in _goals) {
      switch (goal.status) {
        case 'planejada':
          planned++;
          break;
        case 'ativa':
          active++;
          break;
        case 'atingida':
          completed++;
          break;
        case 'cancelada':
          canceled++;
          break;
        case 'pendente':
          pending++;
          break;
      }
    }

    return GoalStatistics(
      plannedCount: planned,
      activeCount: active,
      completedCount: completed,
      canceledCount: canceled,
      pendingCount: pending,
    );
  }

  Future<void> getGoalById(String id) async {
    _setLoading(true);
    _clearError();
    try {
      final goal = await _getGoalByIdUseCase.execute(id);
      if (goal != null) {
        final index = _goals.indexWhere((g) => g.id == id);
        if (index != -1) {
          _goals[index] = goal;
          notifyListeners();
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateGoal(Goal goal) async {
    _setLoading(true);
    _clearError();
    try {
      await _updateGoalUseCase.execute(goal);
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteGoal(String id) async {
    _setLoading(true);
    _clearError();
    try {
      await _deleteGoalUseCase.execute(id);
      _goals.removeWhere((goal) => goal.id == id);
      _filteredGoals = _filteredGoals.where((goal) => goal.id != id).toList();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGoalsByType(String type) async {
    _setLoading(true);
    _clearError();
    try {
      _filteredGoals = await _getGoalsByTypeUseCase.execute(type);
      _selectedTypeFilter = type;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateGoalProgress(String goalId, double newValue) async {
    _setLoading(true);
    _clearError();
    try {
      await _updateGoalProgressUseCase.execute(goalId, newValue);
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        final oldGoal = _goals[index];
        final updatedGoal = oldGoal.copyWith(currentValue: newValue);
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeGoal(String goalId) async {
    _setLoading(true);
    _clearError();
    try {
      await _completeGoalUseCase.execute(goalId);
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        final oldGoal = _goals[index];
        final updatedGoal = oldGoal.copyWith(
          currentValue: oldGoal.targetValue,
          status: 'atingida',
          achievedAt: DateTime.now(),
        );
        _goals[index] = updatedGoal;
        notifyListeners();
      }
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

  Future<int> checkAndUpdateExpiredGoals() async {
    if (_goals.isEmpty) return 0;
    int updatedCount = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    try {
      final List<Goal> updatedList = [];
      bool hasChanges = false;
      for (final goal in _goals) {
        final goalEndDate = DateTime(
          goal.endDate.year,
          goal.endDate.month,
          goal.endDate.day,
        );
        if (goal.status == 'ativa' && goalEndDate.isBefore(today)) {
          final updatedGoal = goal.copyWith(status: 'pendente');
          await _updateGoalUseCase.execute(updatedGoal);
          updatedList.add(updatedGoal);
          updatedCount++;
          hasChanges = true;
        } else {
          updatedList.add(goal);
        }
      }
      if (hasChanges) {
        _goals = updatedList;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao atualizar metas: $e');
      _setError('Erro ao verificar metas expiradas');
    }
    return updatedCount;
  }
}
