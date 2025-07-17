import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String? id;
  final DateTime? achievedAt;
  final DateTime createdAt;
  final String createdBy;
  final double currentValue;
  final DateTime endDate;
  final String entityId;
  final String name;
  final DateTime startDate;
  final String status;
  final String targetUnit;
  final double targetValue;
  final String type;

  Goal({
    this.id,
    required this.achievedAt,
    required this.createdAt,
    required this.createdBy,
    required this.currentValue,
    required this.endDate,
    required this.entityId,
    required this.name,
    required this.startDate,
    required this.status,
    required this.targetUnit,
    required this.targetValue,
    required this.type,
  });

  factory Goal.fromFirestore(Map<String, dynamic> data, String id) {
    return Goal(
      id: id,
      achievedAt: _parseDateTime(data['achievedAt']),
      createdAt: _parseDateTime(data['createdAt']),
      createdBy: data['createdBy'] ?? '',
      currentValue: _parseDouble(data['currentValue']),
      endDate: _parseDateTime(data['endDate']),
      entityId: data['entityId'] ?? '',
      name: data['name'] ?? '',
      startDate: _parseDateTime(data['startDate']),
      status: data['status'] ?? '',
      targetUnit: data['targetUnit'] ?? '',
      targetValue: _parseDouble(data['targetValue']),
      type: data['type'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'achievedAt': Timestamp.fromDate(achievedAt!),
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'currentValue': currentValue,
      'endDate': Timestamp.fromDate(endDate),
      'entityId': entityId,
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'status': status,
      'targetUnit': targetUnit,
      'targetValue': targetValue,
      'type': type,
    };
  }

  Goal copyWith({
    String? id,
    DateTime? achievedAt,
    DateTime? createdAt,
    String? createdBy,
    double? currentValue,
    DateTime? endDate,
    String? entityId,
    String? name,
    DateTime? startDate,
    String? status,
    String? targetUnit,
    double? targetValue,
    String? type,
  }) {
    return Goal(
      id: id ?? this.id,
      achievedAt: achievedAt ?? this.achievedAt,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      currentValue: currentValue ?? this.currentValue,
      endDate: endDate ?? this.endDate,
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      targetUnit: targetUnit ?? this.targetUnit,
      targetValue: targetValue ?? this.targetValue,
      type: type ?? this.type,
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
