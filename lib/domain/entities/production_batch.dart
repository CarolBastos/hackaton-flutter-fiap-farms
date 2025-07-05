import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductionStatus {
  planejado,
  aguardandoInicio,
  emProducao,
  colhido,
  cancelado,
}

class ProductionBatch {
  final String? id;
  final String productId;
  final String productName;
  final String? farmId;
  final DateTime startDate;
  final DateTime estimatedEndDate;
  final DateTime? actualHarvestDate;
  final ProductionStatus status;
  final double estimatedQuantity;
  final double? actualQuantity;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;
  final DateTime lastUpdatedAt;

  ProductionBatch({
    this.id,
    required this.productId,
    required this.productName,
    this.farmId,
    required this.startDate,
    required this.estimatedEndDate,
    this.actualHarvestDate,
    required this.status,
    required this.estimatedQuantity,
    this.actualQuantity,
    this.notes,
    required this.createdAt,
    required this.createdBy,
    required this.lastUpdatedAt,
  });

  factory ProductionBatch.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductionBatch(
      id: id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      farmId: data['farmId'],
      startDate: _parseDateTime(data['startDate']),
      estimatedEndDate: _parseDateTime(data['estimatedEndDate']),
      actualHarvestDate: data['actualHarvestDate'] != null
          ? _parseDateTime(data['actualHarvestDate'])
          : null,
      status: _parseStatus(data['status'] ?? 'planejado'),
      estimatedQuantity: _parseDouble(data['estimatedQuantity']),
      actualQuantity: data['actualQuantity'] != null
          ? _parseDouble(data['actualQuantity'])
          : null,
      notes: data['notes'],
      createdAt: _parseDateTime(data['createdAt']),
      createdBy: data['createdBy'] ?? '',
      lastUpdatedAt: _parseDateTime(data['lastUpdatedAt']),
    );
  }

  static ProductionStatus _parseStatus(String status) {
    switch (status) {
      case 'planejado':
        return ProductionStatus.planejado;
      case 'aguardandoInicio':
        return ProductionStatus.aguardandoInicio;
      case 'emProducao':
        return ProductionStatus.emProducao;
      case 'colhido':
        return ProductionStatus.colhido;
      case 'cancelado':
        return ProductionStatus.cancelado;
      default:
        return ProductionStatus.planejado;
    }
  }

  String get statusString {
    switch (status) {
      case ProductionStatus.planejado:
        return 'Planejado';
      case ProductionStatus.aguardandoInicio:
        return 'Aguardando Início';
      case ProductionStatus.emProducao:
        return 'Em Produção';
      case ProductionStatus.colhido:
        return 'Colhido';
      case ProductionStatus.cancelado:
        return 'Cancelado';
    }
  }

  String get statusEmoji {
    switch (status) {
      case ProductionStatus.planejado:
        return '📋';
      case ProductionStatus.aguardandoInicio:
        return '🟡';
      case ProductionStatus.emProducao:
        return '🌱';
      case ProductionStatus.colhido:
        return '🟢';
      case ProductionStatus.cancelado:
        return '❌';
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'farmId': farmId,
      'startDate': Timestamp.fromDate(startDate),
      'estimatedEndDate': Timestamp.fromDate(estimatedEndDate),
      'actualHarvestDate': actualHarvestDate != null
          ? Timestamp.fromDate(actualHarvestDate!)
          : null,
      'status': status.name,
      'estimatedQuantity': estimatedQuantity.toDouble(),
      'actualQuantity': actualQuantity?.toDouble(),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
    };
  }

  ProductionBatch copyWith({
    String? id,
    String? productId,
    String? productName,
    String? farmId,
    DateTime? startDate,
    DateTime? estimatedEndDate,
    DateTime? actualHarvestDate,
    ProductionStatus? status,
    double? estimatedQuantity,
    double? actualQuantity,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
    DateTime? lastUpdatedAt,
  }) {
    return ProductionBatch(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      farmId: farmId ?? this.farmId,
      startDate: startDate ?? this.startDate,
      estimatedEndDate: estimatedEndDate ?? this.estimatedEndDate,
      actualHarvestDate: actualHarvestDate ?? this.actualHarvestDate,
      status: status ?? this.status,
      estimatedQuantity: estimatedQuantity ?? this.estimatedQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
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
