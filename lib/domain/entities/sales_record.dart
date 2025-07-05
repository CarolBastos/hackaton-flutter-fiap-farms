import 'package:cloud_firestore/cloud_firestore.dart';

class SalesRecord {
  final String? id;
  final String productId;
  final String productName;
  final String? productionBatchId;
  final double quantitySold;
  final String unitOfMeasure;
  final double salePricePerUnit;
  final double totalSaleAmount;
  final double estimatedCostAtSale;
  final double calculatedProfit;
  final DateTime saleDate;
  final String? clientInfo;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  SalesRecord({
    this.id,
    required this.productId,
    required this.productName,
    this.productionBatchId,
    required this.quantitySold,
    required this.unitOfMeasure,
    required this.salePricePerUnit,
    required this.totalSaleAmount,
    required this.estimatedCostAtSale,
    required this.calculatedProfit,
    required this.saleDate,
    this.clientInfo,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  factory SalesRecord.fromFirestore(Map<String, dynamic> data, String id) {
    return SalesRecord(
      id: id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productionBatchId: data['productionBatchId'],
      quantitySold: (data['quantitySold'] ?? 0.0).toDouble(),
      unitOfMeasure: data['unitOfMeasure'] ?? '',
      salePricePerUnit: (data['salePricePerUnit'] ?? 0.0).toDouble(),
      totalSaleAmount: (data['totalSaleAmount'] ?? 0.0).toDouble(),
      estimatedCostAtSale: (data['estimatedCostAtSale'] ?? 0.0).toDouble(),
      calculatedProfit: (data['calculatedProfit'] ?? 0.0).toDouble(),
      saleDate: (data['saleDate'] as Timestamp).toDate(),
      clientInfo: data['clientInfo'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productionBatchId': productionBatchId,
      'quantitySold': quantitySold,
      'unitOfMeasure': unitOfMeasure,
      'salePricePerUnit': salePricePerUnit,
      'totalSaleAmount': totalSaleAmount,
      'estimatedCostAtSale': estimatedCostAtSale,
      'calculatedProfit': calculatedProfit,
      'saleDate': Timestamp.fromDate(saleDate),
      'clientInfo': clientInfo,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  SalesRecord copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productionBatchId,
    double? quantitySold,
    String? unitOfMeasure,
    double? salePricePerUnit,
    double? totalSaleAmount,
    double? estimatedCostAtSale,
    double? calculatedProfit,
    DateTime? saleDate,
    String? clientInfo,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return SalesRecord(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productionBatchId: productionBatchId ?? this.productionBatchId,
      quantitySold: quantitySold ?? this.quantitySold,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      salePricePerUnit: salePricePerUnit ?? this.salePricePerUnit,
      totalSaleAmount: totalSaleAmount ?? this.totalSaleAmount,
      estimatedCostAtSale: estimatedCostAtSale ?? this.estimatedCostAtSale,
      calculatedProfit: calculatedProfit ?? this.calculatedProfit,
      saleDate: saleDate ?? this.saleDate,
      clientInfo: clientInfo ?? this.clientInfo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
