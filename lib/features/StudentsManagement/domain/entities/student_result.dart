import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/student_list_item_entity.dart';

class StudentResult {
  final List<StudentListItemEntity> students;
  final bool hasMorePages;

  StudentResult({required this.students, required this.hasMorePages});
}
