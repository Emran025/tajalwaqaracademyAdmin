import 'package:tajalwaqaracademy/features/TeachersManagement/domain/entities/teacher_list_item_entity.dart';

class TeacherResult {
  final List<TeacherListItemEntity> teachers;
  final bool hasMorePages;

  TeacherResult({required this.teachers, required this.hasMorePages});
}
