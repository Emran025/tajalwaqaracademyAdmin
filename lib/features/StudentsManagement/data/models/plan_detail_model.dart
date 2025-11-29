import 'package:flutter/foundation.dart';
import '../../../../../core/models/tracking_type.dart';
import '../../domain/entities/plan_detail_entity.dart';
import '../../../../core/models/tracking_units.dart';

@immutable
final class PlanDetailModel {
  final TrackingType type;
  final TrackingUnit unit;
  final int amount;

  const PlanDetailModel({
    required this.type,
    required this.unit,
    required this.amount,
  });

  // Factory from JSON (API) - لا تغيير هنا
  factory PlanDetailModel.fromJson(Map<String, dynamic> json) {
    return PlanDetailModel(
      type: TrackingType.fromLabel(json['type'] as String? ?? 'recitation'),
      unit: TrackingUnit.fromLabel(json['unit'] as String? ?? 'page'),
      amount: json['amount'] as int? ?? 0,
    );
  }

  // Factory from Database Map
  factory PlanDetailModel.fromMap(Map<String, dynamic> map) {
    return PlanDetailModel(
      type: TrackingType.fromLabel(map['type'] as String),
      unit: TrackingUnit.fromLabel(map['unit'] as String),
      amount: map['amount'] as int,
    );
  }

  // Unified toMap function
  Map<String, dynamic> toMap({required String planUuid}) {
    return {
      'planUuid': planUuid,
      'type': type.label,
      'unit': unit.label,
      'amount': amount,
      'lastModified': DateTime.now().millisecondsSinceEpoch,
    };
  }

  PlanDetailEntity toEntity() {
    return PlanDetailEntity(type: type, unit: unit, amount: amount);
  }

  factory PlanDetailModel.fromEntity(PlanDetailEntity entity) {
    return PlanDetailModel(
      type: entity.type,
      unit: entity.unit,
      amount: entity.amount,
    );
  }
}
