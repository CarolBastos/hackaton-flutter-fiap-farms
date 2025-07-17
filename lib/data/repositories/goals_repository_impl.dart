import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms/domain/entities/goals.dart';
import 'package:fiap_farms/domain/repositories/goals_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final FirebaseFirestore _firestore;

  GoalRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Goal> createGoal(Goal goal) async {
    final docRef = await _firestore.collection('goals').add(goal.toFirestore());
    return goal.copyWith(id: docRef.id);
  }

  @override
  Future<List<Goal>> getGoals() async {
    final snapshot = await _firestore.collection('goals').get();
    return snapshot.docs
        .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    final doc = await _firestore.collection('goals').doc(id).get();
    if (!doc.exists) return null;
    return Goal.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    if (goal.id == null) throw Exception('Goal ID is null');
    await _firestore
        .collection('goals')
        .doc(goal.id)
        .update(goal.toFirestore());
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _firestore.collection('goals').doc(id).delete();
  }

  @override
  Future<List<Goal>> getGoalsByType(String type) async {
    final snapshot = await _firestore
        .collection('goals')
        .where('type', isEqualTo: type)
        .get();
    return snapshot.docs
        .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<Goal>> getActiveGoals() async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('goals')
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .get();
    return snapshot.docs
        .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<Goal>> getGoalsByStatus(String status) async {
    final snapshot = await _firestore
        .collection('goals')
        .where('status', isEqualTo: status)
        .get();
    return snapshot.docs
        .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> updateGoalProgress(String goalId, double newValue) async {
    if (goalId.isEmpty) {
      throw Exception('ID da meta é obrigatório');
    }
    if (newValue < 0) {
      throw Exception('Valor não pode ser negativo');
    }

    await _firestore.collection('goals').doc(goalId).update({
      'currentValue': newValue,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> completeGoal(String id) async {
    if (id.isEmpty) {
      throw Exception('ID da meta é obrigatório');
    }

    // Primeiro obtemos a meta atual para pegar o targetValue
    final doc = await _firestore.collection('goals').doc(id).get();
    if (!doc.exists) {
      throw Exception('Meta não encontrada');
    }

    final goal = Goal.fromFirestore(doc.data()!, doc.id);

    // Atualiza marcando como completa (currentValue = targetValue)
    await _firestore.collection('goals').doc(id).update({
      'currentValue': goal.targetValue,
      'completedAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
