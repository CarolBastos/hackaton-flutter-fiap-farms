import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String? id;
  final String productId;
  final String productName;
  final String? productionBatchId;
  final double availableQuantity;
  final String unitOfMeasure;
  final double estimatedCostPerUnit;
  final DateTime lastUpdated;
  final String createdBy;

  InventoryItem({
    this.id,
    required this.productId,
    required this.productName,
    this.productionBatchId,
    required this.availableQuantity,
    required this.unitOfMeasure,
    required this.estimatedCostPerUnit,
    required this.lastUpdated,
    required this.createdBy,
  });

  factory InventoryItem.fromFirestore(Map<String, dynamic> data, String id) {
    return InventoryItem(
      id: id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productionBatchId: data['productionBatchId'],
      availableQuantity: (data['availableQuantity'] ?? 0.0).toDouble(),
      unitOfMeasure: data['unitOfMeasure'] ?? '',
      estimatedCostPerUnit: (data['estimatedCostPerUnit'] ?? 0.0).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productionBatchId': productionBatchId,
      'availableQuantity': availableQuantity,
      'unitOfMeasure': unitOfMeasure,
      'estimatedCostPerUnit': estimatedCostPerUnit,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'createdBy': createdBy,
    };
  }

  InventoryItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productionBatchId,
    double? availableQuantity,
    String? unitOfMeasure,
    double? estimatedCostPerUnit,
    DateTime? lastUpdated,
    String? createdBy,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productionBatchId: productionBatchId ?? this.productionBatchId,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      estimatedCostPerUnit: estimatedCostPerUnit ?? this.estimatedCostPerUnit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
