import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  InventoryRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<InventoryItem> createInventoryItem(InventoryItem item) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final itemData = item.toFirestore();
      itemData['createdBy'] = user.uid;
      itemData['lastUpdated'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('inventory').add(itemData);

      return item.copyWith(
        id: docRef.id,
        createdBy: user.uid,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erro ao criar item de inventário: $e');
    }
  }

  @override
  Future<List<InventoryItem>> getInventoryItems() async {
    try {
      final querySnapshot = await _firestore
          .collection('inventory')
          .orderBy('lastUpdated', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar itens de inventário: $e');
    }
  }

  @override
  Future<InventoryItem?> getInventoryItemByProductId(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('inventory')
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return InventoryItem.fromFirestore(
        querySnapshot.docs.first.data(),
        querySnapshot.docs.first.id,
      );
    } catch (e) {
      throw Exception('Erro ao buscar item de inventário: $e');
    }
  }

  @override
  Future<void> updateInventoryItem(InventoryItem item) async {
    try {
      if (item.id == null) {
        throw Exception('ID do item de inventário é obrigatório');
      }

      final updateData = item.toFirestore();
      updateData['lastUpdated'] = FieldValue.serverTimestamp();

      await _firestore.collection('inventory').doc(item.id).update(updateData);
    } catch (e) {
      throw Exception('Erro ao atualizar item de inventário: $e');
    }
  }

  @override
  Future<void> deleteInventoryItem(String id) async {
    try {
      await _firestore.collection('inventory').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar item de inventário: $e');
    }
  }

  @override
  Future<void> addToInventory(String productId, double quantity) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Buscar o item existente
      final existingItem = await getInventoryItemByProductId(productId);

      if (existingItem != null) {
        // Atualizar quantidade existente
        final updatedItem = existingItem.copyWith(
          availableQuantity: existingItem.availableQuantity + quantity,
          lastUpdated: DateTime.now(),
        );
        await updateInventoryItem(updatedItem);
      } else {
        // Buscar informações do produto para criar novo item
        final productDoc = await _firestore
            .collection('products')
            .doc(productId)
            .get();
        if (!productDoc.exists) {
          throw Exception('Produto não encontrado');
        }

        final productData = productDoc.data()!;
        final newItem = InventoryItem(
          productId: productId,
          productName: productData['name'] ?? '',
          availableQuantity: quantity,
          unitOfMeasure: productData['unitOfMeasure'] ?? '',
          estimatedCostPerUnit: (productData['estimatedCostPerUnit'] ?? 0.0)
              .toDouble(),
          lastUpdated: DateTime.now(),
          createdBy: user.uid,
        );
        await createInventoryItem(newItem);
      }
    } catch (e) {
      throw Exception('Erro ao adicionar ao inventário: $e');
    }
  }

  @override
  Future<void> removeFromInventory(String productId, double quantity) async {
    try {
      final existingItem = await getInventoryItemByProductId(productId);
      if (existingItem == null) {
        throw Exception('Item não encontrado no inventário');
      }

      if (existingItem.availableQuantity < quantity) {
        throw Exception('Quantidade insuficiente no inventário');
      }

      final updatedItem = existingItem.copyWith(
        availableQuantity: existingItem.availableQuantity - quantity,
        lastUpdated: DateTime.now(),
      );
      await updateInventoryItem(updatedItem);
    } catch (e) {
      throw Exception('Erro ao remover do inventário: $e');
    }
  }
}
