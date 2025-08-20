

import 'base_teacher_entity.dart';

/// Represents a teacher as displayed in a list.
///
/// This entity contains a minimal set of data required for a summary view,
/// optimizing performance by not loading unnecessary details for lists.
/// It inherits core properties from [BaseTeacherDetailEntity].
import 'package:flutter/material.dart';

@immutable
class TeacherListItemEntity extends BaseTeacherEntity {
  const TeacherListItemEntity({
    required super.id,
    required super.name,
    required super.gender,
    required super.avatar,
    required super.country,
    required super.city,
    required super.status,
  });
}
