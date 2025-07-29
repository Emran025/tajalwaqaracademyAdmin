// features/auth/data/datasources/auth_local_data_source_impl.dart

import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/sign_in_model.dart';
import 'auth_local_data_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Database _db;

  // بدل openAuthDb() حالياً نمرّر Database جاهز من DI
  AuthLocalDataSourceImpl(this._db);

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _db.insert(
        'users',
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      throw CacheException(
        message: 'Failed to add teacher with ID ${user.firstName}.'
      );
    }
  }

  @override
  Future<UserModel?> getLastUser() async {
    try {
      final rows = await _db.query('users', orderBy: 'id DESC', limit: 1);
      if (rows.isEmpty) return null;
      return UserModel.fromDbMap(rows.first);
    } catch (_) {
      throw CacheException(
        message: 'Failed to get teacher.'
      );
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final rows = await _db.query('users');
      return rows.map((r) => UserModel.fromDbMap(r)).toList();
    } catch (_) {
      throw CacheException(
        message: 'Failed to get teachers.'
      );
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final user = await getLastUser();
      user != null ? print(user.email) : null;
      return user != null;
    } catch (_) {
      // إذا وقع خطأ أثناء القراءة، اعتبره غير مسجل
      return false;
    }
  }

  @override
  Future<bool> clearAll() async {
    try {
      final user = await getLastUser();
      user != null ? print(user.email) : null;
      return user != null;
    } catch (_) {
      // إذا وقع خطأ أثناء القراءة، اعتبره غير مسجل
      return false;
    }
  }
}
