import 'package:tajalwaqaracademy/features/TeachersManagement/data/models/teacher_model.dart';

/// A wrapper class to hold the list of teachers and pagination metadata.
import 'package:flutter/material.dart';

@immutable
class PaginatedTeachersResult {
  final List<TeacherModel> teachers;
  final bool hasMorePages;

  const PaginatedTeachersResult({required this.teachers, required this.hasMorePages});
}
