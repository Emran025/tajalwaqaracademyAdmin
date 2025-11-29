import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/user_model.dart';
import 'auth_local_data_source.dart';

// Constants for storage keys
const String _kCurrentUserIdKey =
    'CURRENT_USER_ID'; // Pointer to the active user's ID
const String _kUsersListKey =
    'CACHED_USERS_LIST'; // Stores the list of all logged-in users
const String _kTokenPrefix = 'TOKEN_'; // Prefix for secure token storage

/// The concrete implementation of [AuthLocalDataSource].
///
/// This class manages multiple user sessions:
/// - [SharedPreferences] stores the list of users and the ID of the current active user.
/// - [FlutterSecureStorage] stores tokens unique to each user ID.
@LazySingleton(as: AuthLocalDataSource)
final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
    required FlutterSecureStorage secureStorage,
  }) : _sharedPreferences = sharedPreferences,
       _secureStorage = secureStorage;

  /// Helper: Retrieves the ID of the currently selected user.
  String? _getCurrentUserId() {
    return _sharedPreferences.getString(_kCurrentUserIdKey);
  }

  /// Helper: Retrieves the list of all cached user maps from SharedPreferences.
  List<Map<String, dynamic>> _getUsersListFromPrefs() {
    final String? jsonString = _sharedPreferences.getString(_kUsersListKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheUser(UserModel userToCache) async {
    try {
      final userMap = userToCache.toDbMap();
      // Ensure your UserModel has an 'id' field. We convert it to String for consistency.
      final String userId = userMap['id'].toString();

      // 1. Get existing users list.
      List<Map<String, dynamic>> usersList = _getUsersListFromPrefs();

      // 2. Remove the user if they already exist (to update their data).
      usersList.removeWhere((u) => u['id'].toString() == userId);

      // 3. Add the updated user to the list.
      usersList.add(userMap);

      // 4. Persist the updated list.
      await _sharedPreferences.setString(
        _kUsersListKey,
        json.encode(usersList),
      );

      // 5. Set this user as the Current Active User.
      await _sharedPreferences.setString(_kCurrentUserIdKey, userId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache user profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      // We need the current user ID to associate the tokens with the correct user.
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw CacheException(
          message: 'Cannot cache tokens: No current user selected.',
        );
      }

      // Store tokens with a key specific to this user (e.g., TOKEN_ACCESS_123).
      await _secureStorage.write(
        key: '${_kTokenPrefix}ACCESS_$userId',
        value: accessToken,
      );
      await _secureStorage.write(
        key: '${_kTokenPrefix}REFRESH_$userId',
        value: refreshToken,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache auth tokens: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) return null;

      final usersList = _getUsersListFromPrefs();

      // Find the user object that matches the current ID.
      final currentUserMap = usersList.firstWhere(
        (u) => u['id'].toString() == currentUserId,
        orElse: () => {},
      );

      if (currentUserMap.isEmpty) return null;

      return UserModel.fromDbMap(currentUserMap);
    } catch (e) {
      throw CacheException(
        message: 'Failed to decode cached user: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return null;
      // Retrieve the token specific to the current user.
      return await _secureStorage.read(key: '${_kTokenPrefix}ACCESS_$userId');
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve access token: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return null;
      return await _secureStorage.read(key: '${_kTokenPrefix}REFRESH_$userId');
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve refresh token: ${e.toString()}',
      );
    }
  }

  // --- New Functionality for Multi-User Support ---

  /// Switches the current active session to the user with [userId].
  /// This should be called when the user selects an account from a list.
  @override
  Future<void> switchUser(String userId) async {
    final usersList = _getUsersListFromPrefs();
    final exists = usersList.any((u) => u['id'].toString() == userId);

    if (exists) {
      await _sharedPreferences.setString(_kCurrentUserIdKey, userId);
    } else {
      throw CacheException(message: 'User with ID $userId not found in cache.');
    }
  }

  /// Retrieves all cached users. Useful for displaying the "Switch Account" list.
  @override
  Future<List<UserModel>> getAllCachedUsers() async {
    final usersList = _getUsersListFromPrefs();
    return usersList.map((map) => UserModel.fromDbMap(map)).toList();
  }

  // ------------------------------------------------

  @override
  Future<bool> isLoggedIn() async {
    // We are logged in if there is a pointer to a current user.
    return _sharedPreferences.containsKey(_kCurrentUserIdKey);
  }

  @override
  /// Clears the authentication data for the **current active user** only.
  ///
  /// This performs the following steps:
  /// 1. Deletes the Access and Refresh tokens associated with the current user ID.
  /// 2. Removes the current user's profile from the cached users list.
  /// 3. Removes the 'Current User' pointer.
  /// 4. If other users remain in the list, it automatically switches to the first available user.
  Future<void> clear() async {
    try {
      final currentUserId = _getCurrentUserId();

      if (currentUserId != null) {
        // 1. Delete tokens specific to this user
        await _secureStorage.delete(
          key: '${_kTokenPrefix}ACCESS_$currentUserId',
        );
        await _secureStorage.delete(
          key: '${_kTokenPrefix}REFRESH_$currentUserId',
        );

        // 2. Get the current list and remove this user
        List<Map<String, dynamic>> usersList = _getUsersListFromPrefs();
        usersList.removeWhere((u) => u['id'].toString() == currentUserId);

        // Save the updated list back to SharedPreferences
        await _sharedPreferences.setString(
          _kUsersListKey,
          json.encode(usersList),
        );

        // 3. Remove the pointer to the current user
        await _sharedPreferences.remove(_kCurrentUserIdKey);

        // 4. (Optional) If other users exist, automatically switch to the next one
        if (usersList.isNotEmpty) {
          final nextUserId = usersList.first['id'].toString();
          await _sharedPreferences.setString(_kCurrentUserIdKey, nextUserId);
        }
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to logout current user: ${e.toString()}',
      );
    }
  }

  /// Clears **ALL** authentication data from the device.
  ///
  /// This is a "hard reset" that:
  /// 1. Wipes all data from Secure Storage (all tokens for all users).
  /// 2. Removes the list of cached users.
  /// 3. Removes the current user pointer.
  @override
  Future<void> clearAll() async {
    try {
      // 1. Delete everything in secure storage (Tokens for all users)
      await _secureStorage.deleteAll();

      // 2. Remove the users list and the current user pointer
      await _sharedPreferences.remove(_kUsersListKey);
      await _sharedPreferences.remove(_kCurrentUserIdKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear all data: ${e.toString()}',
      );
    }
  }
}
