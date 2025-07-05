import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/sales_data.dart';
import '../../domain/entities/sales_record.dart';
import '../../domain/repositories/sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SalesRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<SalesData> getSalesData(String period) async {
    // Mock data - será substituído por dados reais do Firestore
    switch (period) {
      case 'Dia':
        return SalesData(
          totalSales: 15000.0,
          totalProfit: 12000.0,
          orders: 25,
          growth: 0.08,
          products: [
            ProductData(name: 'Tomate', profit: 4000.0),
            ProductData(name: 'Alface', profit: 3000.0),
            ProductData(name: 'Cenoura', profit: 2500.0),
            ProductData(name: 'Batata', profit: 1500.0),
            ProductData(name: 'Milho', profit: 1000.0),
          ],
        );
      case 'Semana':
        return SalesData(
          totalSales: 85000.0,
          totalProfit: 68000.0,
          orders: 140,
          growth: 0.15,
          products: [
            ProductData(name: 'Tomate', profit: 22000.0),
            ProductData(name: 'Alface', profit: 18000.0),
            ProductData(name: 'Cenoura', profit: 15000.0),
            ProductData(name: 'Batata', profit: 8000.0),
            ProductData(name: 'Milho', profit: 5000.0),
          ],
        );
      case 'Mês':
        return SalesData(
          totalSales: 320000.0,
          totalProfit: 256000.0,
          orders: 520,
          growth: 0.18,
          products: [
            ProductData(name: 'Tomate', profit: 85000.0),
            ProductData(name: 'Alface', profit: 70000.0),
            ProductData(name: 'Cenoura', profit: 55000.0),
            ProductData(name: 'Batata', profit: 30000.0),
            ProductData(name: 'Milho', profit: 16000.0),
          ],
        );
      case 'Ano':
        return SalesData(
          totalSales: 480000.0,
          totalProfit: 360000.0,
          orders: 1800,
          growth: 0.25,
          products: [
            ProductData(name: 'Tomate', profit: 120000.0),
            ProductData(name: 'Alface', profit: 95000.0),
            ProductData(name: 'Cenoura', profit: 87000.0),
            ProductData(name: 'Batata', profit: 65000.0),
            ProductData(name: 'Milho', profit: 43000.0),
          ],
        );
      default:
        throw Exception('Período inválido');
    }
  }

  @override
  Future<List<ProductData>> getTopProducts(String period) async {
    final salesData = await getSalesData(period);
    return salesData.products;
  }

  // Implementações para SalesRecord
  @override
  Future<SalesRecord> createSalesRecord(SalesRecord salesRecord) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final salesData = salesRecord.toFirestore();
      salesData['createdBy'] = user.uid;
      salesData['createdAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('salesRecords').add(salesData);

      return salesRecord.copyWith(
        id: docRef.id,
        createdBy: user.uid,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erro ao criar registro de venda: $e');
    }
  }

  @override
  Future<List<SalesRecord>> getSalesRecords() async {
    try {
      final querySnapshot = await _firestore
          .collection('salesRecords')
          .orderBy('saleDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SalesRecord.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar registros de venda: $e');
    }
  }

  @override
  Future<List<SalesRecord>> getSalesRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('salesRecords')
          .where(
            'saleDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('saleDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('saleDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SalesRecord.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar registros de venda por período: $e');
    }
  }

  @override
  Future<SalesRecord?> getSalesRecordById(String id) async {
    try {
      final doc = await _firestore.collection('salesRecords').doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return SalesRecord.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Erro ao buscar registro de venda: $e');
    }
  }

  @override
  Future<void> updateSalesRecord(SalesRecord salesRecord) async {
    try {
      if (salesRecord.id == null) {
        throw Exception('ID do registro de venda é obrigatório');
      }

      await _firestore
          .collection('salesRecords')
          .doc(salesRecord.id)
          .update(salesRecord.toFirestore());
    } catch (e) {
      throw Exception('Erro ao atualizar registro de venda: $e');
    }
  }

  @override
  Future<void> deleteSalesRecord(String id) async {
    try {
      await _firestore.collection('salesRecords').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar registro de venda: $e');
    }
  }
}
