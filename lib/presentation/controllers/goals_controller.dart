import 'package:fiap_farms/domain/entities/goals.dart';
import 'package:fiap_farms/domain/usecases/goals_usecases.dart';
import 'package:flutter/material.dart';

class GoalStatistics {
  final int plannedCount;
  final int activeCount;
  final int completedCount;
  final int failedCount;

  GoalStatistics({
    required this.plannedCount,
    required this.activeCount,
    required this.completedCount,
    required this.failedCount,
  });
}

class GoalController extends ChangeNotifier {
  final CreateGoalUseCase _createGoalUseCase;
  final GetGoalsUseCase _getGoalsUseCase;
  final GetGoalByIdUseCase _getGoalByIdUseCase;
  final UpdateGoalUseCase _updateGoalUseCase;
  final DeleteGoalUseCase _deleteGoalUseCase;
  final GetGoalsByTypeUseCase _getGoalsByTypeUseCase;
  final GetActiveGoalsUseCase _getActiveGoalsUseCase;
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
    required GetActiveGoalsUseCase getActiveGoalsUseCase,
    required GetGoalsByStatusUseCase getGoalsByStatusUseCase,
    required UpdateGoalProgressUseCase updateGoalProgressUseCase,
    required CompleteGoalUseCase completeGoalUseCase,
  }) : _createGoalUseCase = createGoalUseCase,
       _getGoalsUseCase = getGoalsUseCase,
       _getGoalByIdUseCase = getGoalByIdUseCase,
       _updateGoalUseCase = updateGoalUseCase,
       _deleteGoalUseCase = deleteGoalUseCase,
       _getGoalsByTypeUseCase = getGoalsByTypeUseCase,
       _getActiveGoalsUseCase = getActiveGoalsUseCase,
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

  Future<void> createGoal(Goal goal) async {
    print('[GoalController] Iniciando criação de meta...');
    _setLoading(true);
    _clearError();

    try {
      // Validação dos campos obrigatórios
      if (goal.name.isEmpty) {
        throw Exception('O nome da meta é obrigatório');
      }
      if (goal.targetValue <= 0) {
        throw Exception('O valor alvo deve ser maior que zero');
      }
      if (goal.startDate.isAfter(goal.endDate)) {
        throw Exception('A data de início não pode ser após a data de término');
      }
      if (goal.createdBy.isEmpty) {
        throw Exception('O criador da meta não está definido');
      }

      print('[GoalController] Campos validados, chamando use case...');
      final newGoal = await _createGoalUseCase.execute(goal);
      
      print('[GoalController] Meta criada no repositório, atualizando estado local...');
      _goals.insert(0, newGoal);
      _filteredGoals = List.from(_goals);
      notifyListeners();
      
      print('[GoalController] Meta criada com sucesso!');
    } catch (e) {
      print('[GoalController] Erro ao criar meta: $e');
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGoals() async {
    _setLoading(true);
    _clearError();

    try {
      _goals = await _getGoalsUseCase.execute();
      _filteredGoals = _goals;
      _selectedStatusFilter = '';
      _selectedTypeFilter = '';
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
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

  Future<void> loadActiveGoals() async {
    _setLoading(true);
    _clearError();

    try {
      _filteredGoals = await _getActiveGoalsUseCase.execute();
      _selectedStatusFilter = 'active';
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
      _filteredGoals = await _getGoalsByStatusUseCase.execute(status);
      _selectedStatusFilter = status;
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

  GoalStatistics getGoalStatistics(DateTime now) {
    int planned = 0;
    int active = 0;
    int completed = 0;
    int failed = 0;

    for (final goal in _goals) {
      if (goal.currentValue >= goal.targetValue) {
        completed++;
      } else if (now.isBefore(goal.startDate)) {
        planned++;
      } else if (now.isAfter(goal.endDate)) {
        failed++;
      } else {
        active++;
      }
    }

    return GoalStatistics(
      plannedCount: planned,
      activeCount: active,
      completedCount: completed,
      failedCount: failed,
    );
  }

  Future<void> clearStatusFilter() async {
    _selectedStatusFilter = '';
    _selectedTypeFilter = '';
    _filteredGoals = _goals;
    notifyListeners();
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