
import '../../data/models/student_model.dart';

/// A wrapper class to hold the list of students and pagination metadata.
class PaginatedStudentsResult {
  final List<StudentModel> students;
  final bool hasMorePages;

  PaginatedStudentsResult({required this.students, required this.hasMorePages});
}
