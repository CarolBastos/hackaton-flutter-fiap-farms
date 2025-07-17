import 'package:fiap_farms/domain/entities/goals.dart';
import 'package:fiap_farms/domain/repositories/goals_repository.dart';

class CreateGoalUseCase {
  final GoalRepository repository;

  CreateGoalUseCase(this.repository);

  Future<Goal> execute(Goal goal) {
    if (goal.name.isEmpty) {
      throw Exception('Título da meta é obrigatório');
    }
    if (goal.targetValue <= 0) {
      throw Exception('Valor alvo deve ser maior que zero');
    }
    if (goal.endDate.isBefore(DateTime.now())) {
      throw Exception('Data limite não pode ser no passado');
    }

    return repository.createGoal(goal);
  }
}

class GetGoalsUseCase {
  final GoalRepository repository;

  GetGoalsUseCase(this.repository);

  Future<List<Goal>> execute() {
    return repository.getGoals();
  }
}

class GetGoalByIdUseCase {
  final GoalRepository repository;

  GetGoalByIdUseCase(this.repository);

  Future<Goal?> execute(String id) {
    if (id.isEmpty) {
      throw Exception('ID da meta é obrigatório');
    }

    return repository.getGoalById(id);
  }
}

class UpdateGoalUseCase {
  final GoalRepository repository;

  UpdateGoalUseCase(this.repository);

  Future<void> execute(Goal goal) {
    if (goal.id!.isEmpty) {
      throw Exception('ID da meta é obrigatório');
    }
    if (goal.name.isEmpty) {
      throw Exception('Título da meta é obrigatório');
    }
    if (goal.targetValue <= 0) {
      throw Exception('Valor alvo deve ser maior que zero');
    }

    return repository.updateGoal(goal);
  }
}

class DeleteGoalUseCase {
  final GoalRepository repository;

  DeleteGoalUseCase(this.repository);

  Future<void> execute(String id) {
    if (id.isEmpty) {
      throw Exception('ID da meta é obrigatório');
    }

    return repository.deleteGoal(id);
  }
}

class GetGoalsByTypeUseCase {
  final GoalRepository repository;

  GetGoalsByTypeUseCase(this.repository);

  Future<List<Goal>> execute(String type) {
    if (type.isEmpty) {
      throw Exception('Tipo da meta é obrigatório');
    }

    return repository.getGoalsByType(type);
  }
}

class GetActiveGoalsUseCase {
  final GoalRepository repository;

  GetActiveGoalsUseCase(this.repository);

  Future<List<Goal>> execute() {
    return repository.getActiveGoals();
  }
}

class GetGoalsByStatusUseCase {
  final GoalRepository repository;

  GetGoalsByStatusUseCase(this.repository);

  Future<List<Goal>> execute(String status) {
    if (status.isEmpty) {
      throw Exception('Status da meta é obrigatório');
    }

    return repository.getGoalsByStatus(status);
  }
}

class UpdateGoalProgressUseCase {
  final GoalRepository repository;

  UpdateGoalProgressUseCase(this.repository);

  Future<void> execute(String goalId, double newValue) {
    if (goalId.isEmpty) {
      throw Exception('ID da meta é obrigatório');
    }
    if (newValue < 0) {
      throw Exception('Valor não pode ser negativo');
    }

    return repository.updateGoalProgress(goalId, newValue);
  }
}

class CompleteGoalUseCase {
  final GoalRepository repository;

  CompleteGoalUseCase(this.repository);

  Future<void> execute(String goalId) {
    if (goalId.isEmpty) {
      throw Exception('ID da meta é obrigatório');
    }

    return repository.completeGoal(goalId);
  }
}