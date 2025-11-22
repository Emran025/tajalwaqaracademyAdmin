import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/plan_detail_entity.dart';

import '../../../../core/models/report_frequency.dart';
@immutable
class FollowUpPlanEntity {
  final String planId;
  final Frequency frequency;
  final String serverPlanId;
  final String? updatedAt;
  final String? createdAt;
  final List<PlanDetailEntity> details;

  const FollowUpPlanEntity({
    required this.planId,
    required this.frequency,
    required this.serverPlanId,
    this.updatedAt,
    this.createdAt,
    required this.details,
  });
}
