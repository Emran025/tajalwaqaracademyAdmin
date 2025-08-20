import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/student_list_item_entity.dart';
import 'package:flutter/material.dart';

@immutable
class StudentResult {
  final List<StudentListItemEntity> students;
  final bool hasMorePages;

  const StudentResult({required this.students, required this.hasMorePages});
}
