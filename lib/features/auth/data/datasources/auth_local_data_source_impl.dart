// lib/features/auth/data/datasources/auth_local_data_source_impl.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tajalwaqaracademy/core/database/app_database.dart';
import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/device_account_model.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/user_model.dart';
import 'auth_local_data_source.dart';

// Define constant keys to prevent typos and centralize management.
const String _kAccessTokenKeyPrefix = 'ACCESS_TOKEN_';
const String _kRefreshTokenKeyPrefix = 'REFRESH_TOKEN_';
const String _kUserCacheKey = 'CACHED_USER';
const String _kLastLoggedInUserIdKey = 'LAST_LOGGED_IN_USER_ID';

/// The concrete implementation of [AuthLocalDataSource].
///
/// This class orchestrates the persistence of authentication data using a
/// combination of secure and standard local storage mechanisms:
/// - [FlutterSecureStorage] is used for sensitive session tokens.
/// - [SharedPreferences] is used for non-sensitive, structured user data.
/// - [AppDatabase] is used to store the list of device accounts.

@LazySingleton(as: AuthLocalDataSource)
final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;
  final AppDatabase _appDatabase;

  AuthLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
    required FlutterSecureStorage secureStorage,
    required AppDatabase appDatabase,
  })  : _sharedPreferences = sharedPreferences,
        _secureStorage = secureStorage,
        _appDatabase = appDatabase;

  @override
  Future<void> cacheAuthTokens({
    required int userId,
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      // Store tokens in secure storage, prefixed with the user ID.
      await _secureStorage.write(
          key: '$_kAccessTokenKeyPrefix$userId', value: accessToken);
      await _secureStorage.write(
          key: '$_kRefreshTokenKeyPrefix$userId', value: refreshToken);
    } catch (e) {
      // Wrap any platform-specific errors in a CacheException.
      throw CacheException(
        message: 'Failed to cache auth tokens: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheUser(UserModel userToCache) async {
    try {
      // 1. Convert the model to a JSON-compatible map.
      final userMap = userToCache.toDbMap();
      // 2. Encode the map into a JSON string.
      final userJsonString = json.encode(userMap);
      // 3. Persist the string in SharedPreferences.
      await _sharedPreferences.setString(_kUserCacheKey, userJsonString);
      // 4. Set the last logged in user ID.
      await _sharedPreferences.setInt(_kLastLoggedInUserIdKey, userToCache.id);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache user profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> getAccessToken(int userId) async {
    try {
      return await _secureStorage.read(key: '$_kAccessTokenKeyPrefix$userId');
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve access token: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> getRefreshToken(int userId) async {
    try {
      return await _secureStorage.read(key: '$_kRefreshTokenKeyPrefix$userId');
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve refresh token: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel?> getUser() async {
    final userJsonString = _sharedPreferences.getString(_kUserCacheKey);
    if (userJsonString != null) {
      try {
        // Decode and parse the JSON string back into a UserModel.
        final userMap = json.decode(userJsonString) as Map<String, dynamic>;
        return UserModel.fromDbMap(userMap);
      } catch (e) {
        // This can happen if the stored data is corrupted or the model has changed.
        throw CacheException(
          message: 'Failed to decode cached user: ${e.toString()}',
        );
      }
    }
    // Return null if no user is found in the cache.
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    // The session is considered active if the user key exists.
    return _sharedPreferences.containsKey(_kUserCacheKey);
  }

  @override
  Future<void> clear(int userId) async {
    try {
      // Clear all related data from both storage mechanisms.
      await _secureStorage.delete(key: '$_kAccessTokenKeyPrefix$userId');
      await _secureStorage.delete(key: '$_kRefreshTokenKeyPrefix$userId');
      await _sharedPreferences.remove(_kUserCacheKey);
      await _sharedPreferences.remove(_kLastLoggedInUserIdKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear authentication cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<DeviceAccountModel>> getDeviceAccounts() async {
    try {
      final db = await _appDatabase.database;
      final maps = await db.query('device_accounts', orderBy: 'lastLogin DESC');
      return maps.map((map) => DeviceAccountModel.fromDbMap(map)).toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve device accounts: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveDeviceAccount(DeviceAccountModel account) async {
    try {
      final db = await _appDatabase.database;
      await db.insert(
        'device_accounts',
        account.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to save device account: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> removeDeviceAccount(int userId) async {
    try {
      final db = await _appDatabase.database;
      await db.delete(
        'device_accounts',
        where: 'id = ?',
        whereArgs: [userId],
      );
      await clear(userId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to remove device account: ${e.toString()}',
      );
    }
  }

  @override
  Future<int?> getLastLoggedInUserId() async {
    return _sharedPreferences.getInt(_kLastLoggedInUserIdKey);
  }
}
