import 'package:tajalwaqaracademy/features/auth/data/models/user_model.dart';

/// Defines the abstract contract for the local data source of authentication.
///
/// This interface specifies the methods for managing session-critical data,
/// such as authentication tokens and the authenticated user's profile, in
/// the local persistence layer.
abstract interface class AuthLocalDataSource {
  /// Caches the session tokens securely.
  ///
  /// - [accessToken]: The token for authenticating API requests.
  /// - [refreshToken]: The token used to obtain a new access token.
  ///
  /// Throws a [CacheException] if the operation fails.
  Future<void> cacheAuthTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Caches the authenticated user's profile data.
  /// Throws a [CacheException] if the operation fails.
  Future<void> cacheUser(UserModel userToCache);

  /// Retrieves the cached access token.
  /// Returns `null` if no token is found.
  Future<String?> getAccessToken();

  /// Retrieves the cached refresh token.
  /// Returns `null` if no token is found.
  Future<String?> getRefreshToken();

  /// Retrieves the last cached user profile.
  /// Returns `null` if no user is cached.
  Future<UserModel?> getUser();

  /// Retrieves the list cached users profiles.
  /// Returns `null` if no user is cached.

  Future<List<UserModel>> getAllCachedUsers();
  Future<void> switchCurrentScreen(String currentScreen);

  /// Checks if there is a user session currently cached.
  ///
  /// Returns `true` if a user is cached, `false` otherwise. This is often
  /// used for initial route guarding or determining the app's starting state.
  Future<String> isLoggedIn();

  /// Clears all authentication-related data (tokens and user profile).
  /// This is typically called during logOut.
  /// Throws a [CacheException] if the operation fails.
  Future<void> clear();

  /// Clears **ALL** authentication data from the device.
  ///
  /// This is a "hard reset" that:
  /// 1. Wipes all data from Secure Storage (all tokens for all users).
  /// 2. Removes the list of cached users.
  /// 3. Removes the current user pointer.
  Future<void> clearAll();

  Future<void> switchUser(String userId);
}
