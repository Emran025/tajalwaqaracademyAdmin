import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/user_model.dart';
import 'auth_local_data_source.dart';

// Constants for SharedPreferences (User Data)
const String _kCurrentScreenKey = 'CURRENT_SCREEN';
const String _kCurrentUserIdKey = 'CURRENT_USER_ID';
const String _kUsersListKey = 'CACHED_USERS_LIST';

// Constants for Secure Storage (Tokens) -> Separated as requested
const String _kAccessTokensListKey = 'ACCESS_TOKENS_LIST';
const String _kRefreshTokensListKey = 'REFRESH_TOKENS_LIST';

/// The concrete implementation of [AuthLocalDataSource].
///
/// This class manages multiple user sessions:
/// - [SharedPreferences] stores user profiles.
/// - [FlutterSecureStorage] stores two separate lists for Access and Refresh tokens.
/// - **Important**: The element at Index [0] of these lists always belongs to the Current User.
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

  /// Helper: Retrieves user profiles from SharedPreferences.
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

  /// Helper: Retrieves a specific token list (Access or Refresh) from Secure Storage.
  /// Structure: List<Map<String, String>> -> [{'uid': '1', 'token': 'xyz'}, ...]
  Future<List<Map<String, String>>> _getTokenList(String key) async {
    try {
      final String? jsonString = await _secureStorage.read(key: key);
      if (jsonString == null) return [];

      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((e) => Map<String, String>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Helper: Saves a specific token list to Secure Storage.
  Future<void> _saveTokenList(
    String key,
    List<Map<String, String>> list,
  ) async {
    await _secureStorage.write(key: key, value: json.encode(list));
  }

  @override
  Future<void> cacheUser(UserModel userToCache) async {
    try {
      final userMap = userToCache.toMap();
      final String userId = userMap['id'].toString();

      // 1. Update users list in SharedPreferences
      List<Map<String, dynamic>> usersList = _getUsersListFromPrefs();
      usersList.removeWhere((u) => u['id'].toString() == userId);

      // Insert at top (Index 0)
      usersList.insert(0, userMap);

      await _sharedPreferences.setString(
        _kUsersListKey,
        json.encode(usersList),
      );

      // 2. Set active user pointer
      await _sharedPreferences.setString(_kCurrentUserIdKey, userId);

      switchCurrentScreen('home');
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
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw CacheException(
          message: 'Cannot cache tokens: No current user selected.',
        );
      }

      // 1. Retrieve both lists
      List<Map<String, String>> accessList = await _getTokenList(
        _kAccessTokensListKey,
      );
      List<Map<String, String>> refreshList = await _getTokenList(
        _kRefreshTokensListKey,
      );

      // 2. Remove existing entries for this user (to update)
      accessList.removeWhere((t) => t['uid'] == userId);
      refreshList.removeWhere((t) => t['uid'] == userId);

      // 3. Insert new tokens at Index 0 (Current User)
      accessList.insert(0, {'uid': userId, 'token': accessToken});
      refreshList.insert(0, {'uid': userId, 'token': refreshToken});

      // 4. Save both lists
      await _saveTokenList(_kAccessTokensListKey, accessList);
      await _saveTokenList(_kRefreshTokensListKey, refreshList);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache auth tokens: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      // Get the list, return the first element's token (Current User)
      final accessList = await _getTokenList(_kAccessTokensListKey);
      if (accessList.isEmpty) return null;

      return accessList.first['token'];
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve access token: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      // Get the list, return the first element's token (Current User)
      final refreshList = await _getTokenList(_kRefreshTokensListKey);
      if (refreshList.isEmpty) return null;

      return refreshList.first['token'];
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve refresh token: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) return null;

      final usersList = _getUsersListFromPrefs();

      final currentUserMap = usersList.firstWhere(
        (u) => u['id'].toString() == currentUserId,
        orElse: () => {},
      );

      if (currentUserMap.isEmpty) return null;

      return UserModel.fromMap(currentUserMap);
    } catch (e) {
      throw CacheException(
        message: 'Failed to decode cached user: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> switchUser(String userId) async {
    // 1. Check User Existence
    final usersList = _getUsersListFromPrefs();
    final userExists = usersList.any((u) => u['id'].toString() == userId);

    if (!userExists) {
      throw CacheException(message: 'User with ID $userId not found in cache.');
    }

    // 2. Update SharedPrefs Pointer
    await _sharedPreferences.setString(_kCurrentUserIdKey, userId);
    switchCurrentScreen('home');

    // 3. Reorder BOTH Secure Token Lists (Move selected user to Index 0)
    try {
      // --- Handle Access Tokens ---
      List<Map<String, String>> accessList = await _getTokenList(
        _kAccessTokensListKey,
      );
      int accessIndex = accessList.indexWhere((t) => t['uid'] == userId);
      if (accessIndex != -1) {
        final item = accessList.removeAt(accessIndex);
        accessList.insert(0, item);
        await _saveTokenList(_kAccessTokensListKey, accessList);
      }

      // --- Handle Refresh Tokens ---
      List<Map<String, String>> refreshList = await _getTokenList(
        _kRefreshTokensListKey,
      );
      int refreshIndex = refreshList.indexWhere((t) => t['uid'] == userId);
      if (refreshIndex != -1) {
        final item = refreshList.removeAt(refreshIndex);
        refreshList.insert(0, item);
        await _saveTokenList(_kRefreshTokensListKey, refreshList);
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to switch token order: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      final currentUserId = _getCurrentUserId();

      if (currentUserId != null) {
        // 1. Remove from Access Tokens List
        List<Map<String, String>> accessList = await _getTokenList(
          _kAccessTokensListKey,
        );
        accessList.removeWhere((t) => t['uid'] == currentUserId);
        await _saveTokenList(_kAccessTokensListKey, accessList);

        // 2. Remove from Refresh Tokens List
        List<Map<String, String>> refreshList = await _getTokenList(
          _kRefreshTokensListKey,
        );
        refreshList.removeWhere((t) => t['uid'] == currentUserId);
        await _saveTokenList(_kRefreshTokensListKey, refreshList);

        // 3. Remove User Profile
        List<Map<String, dynamic>> usersList = _getUsersListFromPrefs();
        usersList.removeWhere((u) => u['id'].toString() == currentUserId);
        await _sharedPreferences.setString(
          _kUsersListKey,
          json.encode(usersList),
        );

        // 4. Clear pointer
        await _sharedPreferences.remove(_kCurrentUserIdKey);

        // 5. Auto-switch to next available user if any
        if (usersList.isNotEmpty) {
          final nextUserId = usersList.first['id'].toString();
          await switchUser(nextUserId);
        } else {
          switchCurrentScreen('login');
        }
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to logout current user: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      await _sharedPreferences.remove(_kUsersListKey);
      await _sharedPreferences.remove(_kCurrentUserIdKey);
      await _sharedPreferences.remove(_kCurrentScreenKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear all data: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<UserModel>> getAllCachedUsers() async {
    final usersList = _getUsersListFromPrefs();
    return usersList.map((map) => UserModel.fromMap(map)).toList();
  }

  @override
  Future<String> isLoggedIn() async {
    return _sharedPreferences.getString(_kCurrentScreenKey) ?? "welcome";
  }

  @override
  Future<void> switchCurrentScreen(String currentScreen) async {
    await _sharedPreferences.setString(_kCurrentScreenKey, currentScreen);
  }
}
