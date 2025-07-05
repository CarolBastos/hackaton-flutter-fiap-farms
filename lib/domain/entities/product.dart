import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String name;
  final String description;
  final String category;
  final String unitOfMeasure;
  final double estimatedCostPerUnit;
  final DateTime createdAt;
  final String createdBy;
  final bool isActive;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.unitOfMeasure,
    required this.estimatedCostPerUnit,
    required this.createdAt,
    required this.createdBy,
    required this.isActive,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    print('Product.fromFirestore: Processando dados: $data');

    DateTime createdAt;
    try {
      if (data['createdAt'] != null) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      print('Product.fromFirestore: Erro ao processar createdAt: $e');
      createdAt = DateTime.now();
    }

    bool isActive;
    try {
      isActive = data['isActive'] ?? true;
    } catch (e) {
      print('Product.fromFirestore: Erro ao processar isActive: $e');
      isActive = true;
    }

    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      unitOfMeasure: data['unitOfMeasure'] ?? '',
      estimatedCostPerUnit: _parseDouble(data['estimatedCostPerUnit']),
      createdAt: createdAt,
      createdBy: data['createdBy'] ?? '',
      isActive: isActive,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'unitOfMeasure': unitOfMeasure,
      'estimatedCostPerUnit': estimatedCostPerUnit.toDouble(),
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'isActive': isActive,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? unitOfMeasure,
    double? estimatedCostPerUnit,
    DateTime? createdAt,
    String? createdBy,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      estimatedCostPerUnit: estimatedCostPerUnit ?? this.estimatedCostPerUnit,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }
}
