// path: lib/features/settings/data/datasources/core_data_local_data_source_impl.dart

import 'package.sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../../../StudentsManagement/data/models/student_model.dart';
import '../../../TeachersManagement/data/models/teacher_model.dart';
import 'core_data_local_data_source.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';

const String _kUsersTable = 'users';

/// Implements the [CoreDataLocalDataSource] contract.
class CoreDataLocalDataSourceImpl implements CoreDataLocalDataSource {
  final Database database;

  CoreDataLocalDataSourceImpl({required this.database});

  @override
  Future<List<StudentModel>> getStudentsForExport() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        _kUsersTable,
        where: 'roleId = ? AND isDeleted = ?',
        whereArgs: [UserRole.student.id, 0],
      );
      return List.generate(maps.length, (i) {
        return StudentModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw CacheException(message: 'Failed to export students: ${e.toString()}');
    }
  }

  @override
  Future<List<TeacherModel>> getTeachersForExport() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        _kUsersTable,
        where: 'roleId = ? AND isDeleted = ?',
        whereArgs: [UserRole.teacher.id, 0],
      );
      return List.generate(maps.length, (i) {
        return TeacherModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw CacheException(message: 'Failed to export teachers: ${e.toString()}');
    }
  }

  @override
  Future<int> importStudents(List<StudentModel> students,
      [String conflictResolution = 'replace']) async {
    try {
      final batch = database.batch();
      for (final student in students) {
        batch.insert(_kUsersTable, student.toDbMap(),
            conflictAlgorithm: conflictResolution == 'skip'
                ? ConflictAlgorithm.ignore
                : ConflictAlgorithm.replace);
      }
      final results = await batch.commit();
      return results.where((r) => r != 0).length;
    } catch (e) {
      throw CacheException(message: 'Failed to import students: ${e.toString()}');
    }
  }

  @override
  Future<int> importTeachers(List<TeacherModel> teachers,
      [String conflictResolution = 'replace']) async {
    try {
      final batch = database.batch();
      for (final teacher in teachers) {
        batch.insert(_kUsersTable, teacher.toDbMap(),
            conflictAlgorithm: conflictResolution == 'skip'
                ? ConflictAlgorithm.ignore
                : ConflictAlgorithm.replace);
      }
      final results = await batch.commit();
      return results.where((r) => r != 0).length;
    } catch (e) {
      throw CacheException(message: 'Failed to import teachers: ${e.toString()}');
    }
  }
}
