// path: lib/features/settings/data/datasources/core_data_local_data_source.dart

import '../../../../core/error/exceptions.dart';
import '../../../StudentsManagement/data/models/student_model.dart';
import '../../../TeachersManagement/data/models/teacher_model.dart';

/// Defines the contract for accessing core application data from local storage.
abstract class CoreDataLocalDataSource {
  /// Fetches a list of students for export.
  ///
  /// Throws a [CacheException] if data cannot be retrieved.
  Future<List<StudentModel>> getStudentsForExport();

  /// Fetches a list of teachers for export.
  ///
  /// Throws a [CacheException] if data cannot be retrieved.
  Future<List<TeacherModel>> getTeachersForExport();

  /// Bulk inserts a list of students.
  ///
  /// Throws a [CacheException] if the import fails.
  /// Returns the number of successfully imported students.
  Future<int> importStudents(List<StudentModel> students,
      [String conflictResolution]);

  /// Bulk inserts a list of teachers.
  ///
  /// Throws a [CacheException] if the import fails.
  /// Returns the number of successfully imported teachers.
  Future<int> importTeachers(List<TeacherModel> teachers,
      [String conflictResolution]);
}
