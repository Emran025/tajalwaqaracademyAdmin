import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/data/models/plan_detail_model.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/follow_up_plan_entity.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/models/report_frequency.dart';

@immutable
final class FollowUpPlanModel {
  final String planId; // سيتم استخدام UUID الآن
  final String serverPlanId;
  final Frequency frequency;
  final String? updatedAt;
  final String? createdAt;
  final List<PlanDetailModel> details;

  const FollowUpPlanModel({
    required this.planId,
    required this.frequency,
    required this.serverPlanId,
    this.updatedAt,
    this.createdAt,
    required this.details,
  });

  factory FollowUpPlanModel.fromJson(Map<String, dynamic> json) {
    final detailsListJson = json['details'] as List<dynamic>? ?? [];
    if (detailsListJson.isEmpty) {
      return FollowUpPlanModel(
        planId: const Uuid().v4(),
        serverPlanId: json['PlanId'].toString(),
        frequency: Frequency.fromLabel( json['frequency'] as String? ?? 'daily'),
        updatedAt:
            json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
        createdAt:
            json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
        details: [],
      );
    }
    final details = detailsListJson
        .map((dJson) => PlanDetailModel.fromJson(dJson as Map<String, dynamic>))
        .toList();

    return FollowUpPlanModel(
      planId: const Uuid().v4(),
      serverPlanId: json['PlanId'].toString(),
frequency: Frequency.fromLabel( json['frequency'] as String? ?? 'daily'),      updatedAt: json['updatedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      details: details,
    );
  }

  // Factory from multiple database maps (Plan + Details)
  factory FollowUpPlanModel.fromDbMaps({
    required Map<String, dynamic> planMap,
    required List<Map<String, dynamic>> detailsMaps,
  }) {
    final details = detailsMaps
        .map((map) => PlanDetailModel.fromDbMap(map))
        .toList();
    return FollowUpPlanModel(
      planId: planMap['uuid'] as String,
      serverPlanId: planMap['server_plan_id'].toString(),
      frequency: Frequency.fromId( planMap['frequency'] as int? ?? 1),
      
      createdAt: planMap['createdAt'] as String?,
      updatedAt: planMap['updatedAt'] as String?,
      details: details,
    );
  }

  // toMap for the main plan table (_kFollowUpPlansTable)
  Map<String, dynamic> toPlanDbMap(int enrollmentId) {
    return {
      'uuid': planId,
      'server_plan_id': serverPlanId,
      'enrollmentId': enrollmentId,
      'frequency': frequency.id,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
      'updatedAt': updatedAt ?? DateTime.now().toIso8601String(),
      'lastModified': DateTime.now().millisecondsSinceEpoch,
      'isDeleted': details.isNotEmpty ? 0 : 1,
    };
  }

  FollowUpPlanEntity toEntity() {
    return FollowUpPlanEntity(
      planId: planId,
      frequency: frequency,
      serverPlanId: serverPlanId,
      updatedAt: updatedAt,
      createdAt: createdAt,
      details: details.map((dModel) => dModel.toEntity()).toList(),
    );
  }

  factory FollowUpPlanModel.fromEntity(FollowUpPlanEntity entity) {
    final details = entity.details
        .map((d) => PlanDetailModel.fromEntity(d))
        .toList();
    return FollowUpPlanModel(
      planId: entity.planId,
      serverPlanId: entity.serverPlanId,
      frequency: entity.frequency,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      details: details,
    );
  }
}
