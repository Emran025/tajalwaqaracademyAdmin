// features/auth/data/datasources/auth_local_data_source.dart

import '../models/sign_in_model.dart';

/// Defines local data operations for authentication,
/// backed by a SQLite database.
abstract class AuthLocalDataSource {
  /// Caches the given [user] in the local database.
  /// Should insert or update the user record.
  Future<void> cacheUser(UserModel user);

  /// Retrieves the most recently cached user,
  /// or returns `null` if no user is stored.
  Future<UserModel?> getLastUser();

  /// Returns a list of all cached users.
  Future<List<UserModel>> getAllUsers();

  Future<bool> isLoggedIn();
  Future<bool> clearAll(); // أو دالة تمسح جدول المستخدم

}
