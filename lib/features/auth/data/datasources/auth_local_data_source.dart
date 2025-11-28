// lib/features/auth/data/datasources/auth_local_data_source.dart

import 'package:tajalwaqaracademy/features/auth/data/models/device_account_model.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/user_model.dart';

/// Defines the abstract contract for the local data source of authentication.
///
/// This interface specifies the methods for managing session-critical data,
/// such as authentication tokens and the authenticated user's profile, in
/// the local persistence layer.
abstract interface class AuthLocalDataSource {
  /// Caches the session tokens securely for a given user.
  ///
  /// - [userId]: The ID of the user to whom the tokens belong.
  /// - [accessToken]: The token for authenticating API requests.
  /// - [refreshToken]: The token used to obtain a new access token.
  ///
  /// Throws a [CacheException] if the operation fails.
  Future<void> cacheAuthTokens({
    required int userId,
    required String accessToken,
    required String refreshToken,
  });

  /// Caches the authenticated user's profile data.
  /// Throws a [CacheException] if the operation fails.
  Future<void> cacheUser(UserModel userToCache);

  /// Retrieves the cached access token for a given user.
  /// Returns `null` if no token is found.
  Future<String?> getAccessToken(int userId);

  /// Retrieves the cached refresh token for a given user.
  /// Returns `null` if no token is found.
  Future<String?> getRefreshToken(int userId);

  /// Retrieves the last cached user profile.
  /// Returns `null` if no user is cached.
  Future<UserModel?> getUser();

  /// Checks if there is a user session currently cached.
  ///
  /// Returns `true` if a user is cached, `false` otherwise. This is often
  /// used for initial route guarding or determining the app's starting state.
  Future<bool> isLoggedIn();

  /// Clears all authentication-related data (tokens and user profile) for a given user.
  /// This is typically called during logOut.
  /// Throws a [CacheException] if the operation fails.
  Future<void> clear(int userId);

  /// --- Multi-User Management ---

  /// Retrieves a list of all user accounts that have been logged into on this device.
  Future<List<DeviceAccountModel>> getDeviceAccounts();

  /// Saves a user account to the device's list of accounts.
  /// If the user already exists, their information (name, avatar, lastLogin) is updated.
  Future<void> saveDeviceAccount(DeviceAccountModel account);

  /// Removes a user account from the device's list.
  /// This also clears their auth tokens.
  Future<void> removeDeviceAccount(int userId);

  /// Gets the ID of the last user who logged in.
  /// Returns `null` if no user has logged in before.
  Future<int?> getLastLoggedInUserId();
}
