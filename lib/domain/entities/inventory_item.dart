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
      availableQuantity: _parseDouble(data['availableQuantity']),
      unitOfMeasure: data['unitOfMeasure'] ?? '',
      estimatedCostPerUnit: _parseDouble(data['estimatedCostPerUnit']),
      lastUpdated: _parseDateTime(data['lastUpdated']),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productionBatchId': productionBatchId,
      'availableQuantity': availableQuantity.toDouble(),
      'unitOfMeasure': unitOfMeasure,
      'estimatedCostPerUnit': estimatedCostPerUnit.toDouble(),
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

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('InventoryItem._parseDateTime: Erro ao processar data: $e');
        return DateTime.now();
      }
    }

    return DateTime.now();
  }
}
