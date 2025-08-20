// import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/follow_up_plan_entity.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/halqa_entity.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/student_entity.dart';

/// Represents the full, detailed profile of a single student.
///
/// This entity includes all available information for a student, used when
/// viewing a specific student's profile. It inherits core properties and
/// adds detailed fields.
@immutable
class StudentInfoEntity {
  final StudentDetailEntity studentDetailEntity;
  final AssignedHalaqasEntity assignedHalaqa; // <<< Single Halqa, not a list
  final FollowUpPlanEntity followUpPlan; // <<< FollowUpPlan object

  const StudentInfoEntity({
    required this.studentDetailEntity,
    required this.assignedHalaqa,
    required this.followUpPlan,
  });
}
