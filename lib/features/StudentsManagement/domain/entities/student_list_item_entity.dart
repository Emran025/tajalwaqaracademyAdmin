import 'package:flutter/material.dart';

import 'base_student_entity.dart';

/// Represents a student as displayed in a list.

/// This entity contains a minimal set of data required for a summary view,
/// optimizing performance by not loading unnecessary details for lists.
/// It inherits core properties from [BaseStudentDetailEntity].
@immutable
class StudentListItemEntity extends BaseStudentEntity {
  const StudentListItemEntity({
    required super.id,
    required super.name,
    required super.gender,
    required super.avatar,
    required super.country,
    required super.city,
    required super.status,
  });
}
