import 'package:tajalwaqaracademy/features/TeachersManagement/data/models/teacher_model.dart';

/// A wrapper class to hold the list of teachers and pagination metadata.
class PaginatedTeachersResult {
  final List<TeacherModel> teachers;
  final bool hasMorePages;

  PaginatedTeachersResult({required this.teachers, required this.hasMorePages});
}
