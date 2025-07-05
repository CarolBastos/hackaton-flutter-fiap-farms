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
      quantitySold: _parseDouble(data['quantitySold']),
      unitOfMeasure: data['unitOfMeasure'] ?? '',
      salePricePerUnit: _parseDouble(data['salePricePerUnit']),
      totalSaleAmount: _parseDouble(data['totalSaleAmount']),
      estimatedCostAtSale: _parseDouble(data['estimatedCostAtSale']),
      calculatedProfit: _parseDouble(data['calculatedProfit']),
      saleDate: _parseDateTime(data['saleDate']),
      clientInfo: data['clientInfo'],
      notes: data['notes'],
      createdAt: _parseDateTime(data['createdAt']),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productionBatchId': productionBatchId,
      'quantitySold': quantitySold.toDouble(),
      'unitOfMeasure': unitOfMeasure,
      'salePricePerUnit': salePricePerUnit.toDouble(),
      'totalSaleAmount': totalSaleAmount.toDouble(),
      'estimatedCostAtSale': estimatedCostAtSale.toDouble(),
      'calculatedProfit': calculatedProfit.toDouble(),
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
        return DateTime.now();
      }
    }

    return DateTime.now();
  }
}
