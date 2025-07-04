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
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      unitOfMeasure: data['unitOfMeasure'] ?? '',
      estimatedCostPerUnit: (data['estimatedCostPerUnit'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'unitOfMeasure': unitOfMeasure,
      'estimatedCostPerUnit': estimatedCostPerUnit,
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
}
