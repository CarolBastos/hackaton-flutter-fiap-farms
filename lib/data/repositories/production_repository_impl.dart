import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/production_batch.dart';
import '../../domain/repositories/production_repository.dart';

class ProductionRepositoryImpl implements ProductionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProductionRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<ProductionBatch> createProductionBatch(ProductionBatch batch) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final batchData = batch.toFirestore();
      batchData['createdBy'] = user.uid;
      batchData['createdAt'] = FieldValue.serverTimestamp();
      batchData['lastUpdatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection('productionBatches')
          .add(batchData);

      return batch.copyWith(
        id: docRef.id,
        createdBy: user.uid,
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erro ao criar lote de produção: $e');
    }
  }

  @override
  Future<List<ProductionBatch>> getProductionBatches() async {
    try {
      final querySnapshot = await _firestore
          .collection('productionBatches')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductionBatch.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar lotes de produção: $e');
    }
  }

  @override
  Future<List<ProductionBatch>> getProductionBatchesByStatus(
    String status,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('productionBatches')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductionBatch.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar lotes por status: $e');
    }
  }

  @override
  Future<ProductionBatch?> getProductionBatchById(String id) async {
    try {
      final doc = await _firestore
          .collection('productionBatches')
          .doc(id)
          .get();

      if (!doc.exists) {
        return null;
      }

      return ProductionBatch.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Erro ao buscar lote: $e');
    }
  }

  @override
  Future<void> updateProductionBatch(ProductionBatch batch) async {
    try {
      if (batch.id == null) {
        throw Exception('ID do lote é obrigatório para atualização');
      }

      final updateData = batch.toFirestore();
      updateData['lastUpdatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('productionBatches')
          .doc(batch.id)
          .update(updateData);
    } catch (e) {
      throw Exception('Erro ao atualizar lote: $e');
    }
  }

  @override
  Future<void> updateProductionStatus(String id, String status) async {
    try {
      await _firestore.collection('productionBatches').doc(id).update({
        'status': status,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar status: $e');
    }
  }

  @override
  Future<void> deleteProductionBatch(String id) async {
    try {
      await _firestore.collection('productionBatches').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar lote: $e');
    }
  }
}
