import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms/domain/entities/goals.dart';
import 'package:fiap_farms/domain/repositories/goals_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final FirebaseFirestore _firestore;

  GoalRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Goal> createGoal(Goal goal) async {
    try {
      print('Enviando meta para o Firestore: ${goal.toFirestore()}');

      final goalData = goal.toFirestore();
      final docRef = await _firestore.collection('goals').add(goalData);

      print('Meta criada com ID: ${docRef.id}');
      return goal.copyWith(id: docRef.id);
    } catch (e, stackTrace) {
      print('Erro ao criar meta no Firestore: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<Goal>> getGoals() async {
    try {
      final snapshot = await _firestore.collection('goals').get();
      return snapshot.docs
          .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar metas: $e');
      rethrow;
    }
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      final doc = await _firestore.collection('goals').doc(id).get();
      if (!doc.exists) {
        print('Meta com ID $id não encontrada');
        return null;
      }
      return Goal.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      print('Erro ao buscar meta por ID: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    try {
      if (goal.id == null) {
        throw Exception('ID da meta não pode ser nulo para atualização');
      }

      print('Atualizando meta ${goal.id} com dados: ${goal.toFirestore()}');
      await _firestore
          .collection('goals')
          .doc(goal.id)
          .update(goal.toFirestore());
    } catch (e) {
      print('Erro ao atualizar meta: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      print('Deletando meta com ID: $id');
      await _firestore.collection('goals').doc(id).delete();
    } catch (e) {
      print('Erro ao deletar meta: $e');
      rethrow;
    }
  }

  @override
  Future<List<Goal>> getGoalsByType(String type) async {
    try {
      final snapshot = await _firestore
          .collection('goals')
          .where('type', isEqualTo: type)
          .get();
      return snapshot.docs
          .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar metas por tipo: $e');
      rethrow;
    }
  }

  @override
  Future<List<Goal>> getActiveGoals() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('goals')
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .get();
      return snapshot.docs
          .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar metas ativas: $e');
      rethrow;
    }
  }

  @override
  Future<List<Goal>> getGoalsByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection('goals')
          .where('status', isEqualTo: status)
          .get();
      return snapshot.docs
          .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar metas por status: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateGoalProgress(String goalId, double newValue) async {
    try {
      if (goalId.isEmpty) {
        throw Exception('ID da meta é obrigatório');
      }
      if (newValue < 0) {
        throw Exception('Valor não pode ser negativo');
      }

      print('Atualizando progresso da meta $goalId para $newValue');
      await _firestore.collection('goals').doc(goalId).update({
        'currentValue': newValue,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao atualizar progresso da meta: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeGoal(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID da meta é obrigatório');
      }

      print('Completando meta com ID: $id');
      final doc = await _firestore.collection('goals').doc(id).get();
      if (!doc.exists) {
        throw Exception('Meta não encontrada');
      }

      final goal = Goal.fromFirestore(doc.data()!, doc.id);

      await _firestore.collection('goals').doc(id).update({
        'currentValue': goal.targetValue,
        'status': 'atingida',
        'achievedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao completar meta: $e');
      rethrow;
    }
  }
}
