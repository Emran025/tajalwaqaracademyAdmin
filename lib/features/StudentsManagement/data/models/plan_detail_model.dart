import 'package:flutter/foundation.dart';
import 'package:tajalwaqaracademy/core/models/tracking_type.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/plan_detail_entity.dart';

import '../../../../core/models/tracking_units.dart';

/// Data model for a single detail within a student's follow-up plan.
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

  factory PlanDetailModel.fromJson(Map<String, dynamic> json) {
    return PlanDetailModel(
      type: TrackingType.fromLabel(json['type'] as String? ?? 'recitation'),
      unit: TrackingUnit.fromLabel(json['unit'] as String? ?? 'page'),
      amount: json['amount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type.label, 'unit': unit.label, 'amount': amount};
  }

  PlanDetailEntity toEntity() {
    return PlanDetailEntity(type: type, unit: unit, amount: amount);
  }

  Map<String, dynamic> toDbMap() {
    // For saving to plan_details table
    return {'type': type, 'unit': unit, 'amount': amount};
  }
}
