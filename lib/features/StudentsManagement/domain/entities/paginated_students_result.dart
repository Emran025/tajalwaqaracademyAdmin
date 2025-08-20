
import '../../data/models/student_model.dart';
import 'package:flutter/material.dart';

/// A wrapper class to hold the list of students and pagination metadata.
@immutable
class PaginatedStudentsResult {
  final List<StudentModel> students;
  final bool hasMorePages;

  const PaginatedStudentsResult({required this.students, required this.hasMorePages});
}
