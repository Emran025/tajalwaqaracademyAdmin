import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/plan_detail_entity.dart';

class FollowUpPlanEntity {
  final String planId; // Maps to PlanId in JSON, primary key in DB
  final String frequency;
  final String studentId;
  final String? updatedAt;
  final String? createdAt;
  final List<PlanDetailEntity> details;

  const FollowUpPlanEntity({
    required this.planId,
    required this.studentId,
    required this.frequency,
    this.updatedAt,
    this.createdAt,
    required this.details,
  });}












