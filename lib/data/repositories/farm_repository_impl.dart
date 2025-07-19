import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms/domain/entities/farm.dart';
import 'package:fiap_farms/domain/repositories/farm_repository.dart';

class FarmRepositoryImpl implements FarmRepository {
  final FirebaseFirestore _firestore;

  FarmRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Farm> createFarm(Farm farm) async {
    final data = _farmToFirestore(farm);
    final docRef = await _firestore.collection('farms').add(data);
    return _farmFromFirestore(data, docRef.id);
  }

  @override
  Future<void> deleteFarm(String id) async {
    await _firestore.collection('farms').doc(id).delete();
  }

  @override
  Future<List<Farm>> getFarms() async {
    final snapshot = await _firestore.collection('farms').get();
    return snapshot.docs
        .map((doc) => _farmFromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Farm> getFarmById(String id) async {
    final doc = await _firestore.collection('farms').doc(id).get();
    if (!doc.exists) throw Exception('Fazenda não encontrada');
    return _farmFromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<void> updateFarm(Farm farm) async {
    if (farm.id.isEmpty) throw Exception('Fazenda sem ID não pode ser atualizada');
    await _firestore.collection('farms').doc(farm.id).update(_farmToFirestore(farm));
  }

   @override
  Future<double> getTotalAnnualProduction() async {
    final snapshot = await _firestore.collection('farms').get();
    
    double total = 0.0;
    for (final doc in snapshot.docs) {
      final production = doc.data()['annualProduction'] ?? 0.0;
      total += production is int ? production.toDouble() : production;
    }
    return total;
  }

  // Métodos auxiliares para conversão entre Firestore e Entidade
  Map<String, dynamic> _farmToFirestore(Farm farm) {
    return {
      'name': farm.name,
      'productType': farm.productType,
      'annualProduction': farm.annualProduction,
      'address': farm.address,
      'area': farm.area,
      'establishedDate': farm.establishedDate != null
          ? Timestamp.fromDate(farm.establishedDate!)
          : null,
      'location': GeoPoint(
        farm.location.latitude,
        farm.location.longitude,
      ),
    };
  }

  Farm _farmFromFirestore(Map<String, dynamic> data, String id) {
    final geoPoint = data['location'] as GeoPoint;
    final establishedDate = data['establishedDate'] as Timestamp?;

    return Farm(
      id: id,
      name: data['name'] ?? '',
      productType: data['productType'] ?? '',
      annualProduction: (data['annualProduction'] ?? 0.0).toDouble(),
      location: Location(
        latitude: geoPoint.latitude,
        longitude: geoPoint.longitude,
      ),
      address: data['address'],
      area: (data['area'] ?? 0.0).toDouble(),
      establishedDate: establishedDate?.toDate(),
    );
  }
}