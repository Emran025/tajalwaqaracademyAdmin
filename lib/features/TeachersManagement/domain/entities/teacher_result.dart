import 'package:tajalwaqaracademy/features/TeachersManagement/domain/entities/teacher_list_item_entity.dart';
import 'package:flutter/material.dart';

@immutable
class TeacherResult {
  final List<TeacherListItemEntity> teachers;
  final bool hasMorePages;

 const TeacherResult({required this.teachers, required this.hasMorePages});
}
