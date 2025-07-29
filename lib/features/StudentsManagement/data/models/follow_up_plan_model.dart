import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/data/models/plan_detail_model.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/follow_up_plan_entity.dart';

/// Data model for a student's follow-up plan.
/// Contains details of what and how much a student needs to memorize/review.
@immutable
final class FollowUpPlanModel {
  final int planId; // Maps to PlanId in JSON, primary key in DB
  final int studentId; // Maps to PlanId in JSON, primary key in DB
  final String frequency;
  final String? updatedAt;
  final String? createdAt;
  final List<PlanDetailModel> details;

  const FollowUpPlanModel({
    required this.planId,
    required this.studentId,
    required this.frequency,
    this.updatedAt,
    this.createdAt,
    required this.details,
  });

  factory FollowUpPlanModel.fromJson(Map<String, dynamic> json) {
    final detailsListJson = json['details'] as List<dynamic>? ?? [];
    final details = detailsListJson
        .map((dJson) => PlanDetailModel.fromJson(dJson as Map<String, dynamic>))
        .toList();

    return FollowUpPlanModel(
      planId: json['PlanId'] as int? ?? 0,
      studentId: json['studentId'] as int? ?? 0,
      frequency: json['frequency'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      details: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PlanId': planId,
      'studentId': studentId,
      'frequency': frequency,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      'details': details.map((d) => d.toJson()).toList(),
    };
  }

  FollowUpPlanEntity toEntity() {
    return FollowUpPlanEntity(
      planId: planId.toString(),
      studentId: studentId.toString(),
      frequency: frequency,
      updatedAt: updatedAt,
      createdAt: createdAt,
      details: details.map((dModel) => dModel.toEntity()).toList(),
    );
  }
}
