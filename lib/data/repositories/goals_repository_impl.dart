import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/goals.dart';
import '../../domain/repositories/goals_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final FirebaseFirestore _firestore;

  GoalRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Goal> createGoal(Goal goal) async {
    final data = goal.toFirestore();
    final docRef = await _firestore.collection('goals').add(data);
    return goal.copyWith(id: docRef.id);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _firestore.collection('goals').doc(id).delete();
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
    final now = Timestamp.fromDate(DateTime.now());

    final snapshot = await _firestore
        .collection('goals')
        .where('status', isEqualTo: 'ativa')
        .where('startDate', isLessThanOrEqualTo: now)
        .where('endDate', isGreaterThanOrEqualTo: now)
        .get();

    return snapshot.docs
        .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    if (goal.id == null) throw Exception('Meta sem ID não pode ser atualizada');
    await _firestore.collection('goals').doc(goal.id).update(goal.toFirestore());
  }

  @override
  Future<void> updateGoalProgress(String goalId, double newValue) async {
    await _firestore.collection('goals').doc(goalId).update({
      'currentValue': newValue,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> completeGoal(String id) async {
    final doc = await _firestore.collection('goals').doc(id).get();
    if (!doc.exists) throw Exception('Meta não encontrada');

    final data = doc.data()!;
    final currentValue = data['currentValue'] ?? 0.0;
    final targetValue = data['targetValue'] ?? 0.0;

    await _firestore.collection('goals').doc(id).update({
      'currentValue': currentValue >= targetValue ? currentValue : targetValue,
      'status': 'atingida',
      'achievedAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
