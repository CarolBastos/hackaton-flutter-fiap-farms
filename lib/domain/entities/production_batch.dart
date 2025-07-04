import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductionStatus {
  planejado,
  aguardando_inicio,
  em_producao,
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
      startDate: (data['startDate'] as Timestamp).toDate(),
      estimatedEndDate: (data['estimatedEndDate'] as Timestamp).toDate(),
      actualHarvestDate: data['actualHarvestDate'] != null
          ? (data['actualHarvestDate'] as Timestamp).toDate()
          : null,
      status: _parseStatus(data['status'] ?? 'planejado'),
      estimatedQuantity: (data['estimatedQuantity'] ?? 0.0).toDouble(),
      actualQuantity: data['actualQuantity'] != null
          ? (data['actualQuantity'] as num).toDouble()
          : null,
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
    );
  }

  static ProductionStatus _parseStatus(String status) {
    switch (status) {
      case 'planejado':
        return ProductionStatus.planejado;
      case 'aguardando_inicio':
        return ProductionStatus.aguardando_inicio;
      case 'em_producao':
        return ProductionStatus.em_producao;
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
      case ProductionStatus.aguardando_inicio:
        return 'Aguardando Início';
      case ProductionStatus.em_producao:
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
      case ProductionStatus.aguardando_inicio:
        return '🟡';
      case ProductionStatus.em_producao:
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
      'estimatedQuantity': estimatedQuantity,
      'actualQuantity': actualQuantity,
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
}
