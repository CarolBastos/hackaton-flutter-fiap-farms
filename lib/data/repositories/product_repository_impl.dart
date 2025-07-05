import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProductRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final productData = product.toFirestore();
      productData['createdBy'] = user.uid;
      productData['createdAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('products').add(productData);

      return product.copyWith(
        id: docRef.id,
        createdBy: user.uid,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erro ao criar produto: $e');
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final products = querySnapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();

      return products;
    } catch (e) {
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return Product.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Erro ao buscar produto: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      if (product.id == null) {
        throw Exception('ID do produto é obrigatório para atualização');
      }

      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toFirestore());
    } catch (e) {
      throw Exception('Erro ao atualizar produto: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar produto: $e');
    }
  }
}
