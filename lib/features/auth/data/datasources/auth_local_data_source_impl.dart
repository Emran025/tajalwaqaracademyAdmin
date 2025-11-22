import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/user_model.dart';
import 'auth_local_data_source.dart';

// Define constant keys to prevent typos and centralize management.
const String _kAccessTokenKey = 'ACCESS_TOKEN';
const String _kRefreshTokenKey = 'REFRESH_TOKEN';
const String _kUserCacheKey = 'CACHED_USER';

/// The concrete implementation of [AuthLocalDataSource].
///
/// This class orchestrates the persistence of authentication data using a
/// combination of secure and standard local storage mechanisms:
/// - [FlutterSecureStorage] is used for sensitive session tokens.
/// - [SharedPreferences] is used for non-sensitive, structured user data.

@LazySingleton(as: AuthLocalDataSource)
final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
    required FlutterSecureStorage secureStorage,
  }) : _sharedPreferences = sharedPreferences,
       _secureStorage = secureStorage;

  @override
  Future<void> cacheAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      // Store tokens in secure storage.
      await _secureStorage.write(key: _kAccessTokenKey, value: accessToken);
      await _secureStorage.write(key: _kRefreshTokenKey, value: refreshToken);
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
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache user profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _kAccessTokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve access token: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _kRefreshTokenKey);
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
  Future<void> clear() async {
    try {
      // Clear all related data from both storage mechanisms.
      await _secureStorage.deleteAll();
      await _sharedPreferences.remove(_kUserCacheKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear authentication cache: ${e.toString()}',
      );
    }
  }
}
