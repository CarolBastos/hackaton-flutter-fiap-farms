import 'package:fiap_farms/domain/entities/goals.dart';

abstract class GoalRepository {
  Future<Goal> createGoal(Goal goal);
  Future<List<Goal>> getGoals();
  Future<Goal?> getGoalById(String id);
  Future<void> updateGoal(Goal goal);
  Future<void> updateGoalProgress(String goalId, double newValue);
  Future<void> deleteGoal(String id);
  Future<void> completeGoal(String id);

  // Métodos adicionais específicos para metas
  Future<List<Goal>> getGoalsByType(String type);
  Future<List<Goal>> getActiveGoals();
  Future<List<Goal>> getGoalsByStatus(String status);
}
