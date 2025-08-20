// path: lib/features/settings/data/datasources/settings_remote_data_source.dart

import 'package:tajalwaqaracademy/features/settings/domain/entities/user_profile_entity.dart';

import '../models/privacy_policy_model.dart';
import '../models/user_profile_model.dart';

/// Defines the contract for fetching and updating user profile data from the remote API.
///
/// This abstraction ensures the repository is decoupled from the specific
/// implementation details of the API client (e.g., http, dio).
abstract class SettingsRemoteDataSource {
  /// Fetches the user profile from the backend.
  ///
  /// Throws a [ServerException] for all API-related errors.
  Future<UserProfileModel> getUserProfile();

  /// Submits updated user profile data to the backend.
  ///
  /// - [profile]: The updated profile model to be saved.
  /// Returns [void] on success.
  /// Throws a [ServerException] for all API-related errors.
  Future<void> updateUserProfile(UserProfileEntity profile);

  /// NEW: Fetches the latest privacy policy document from the remote API.
  /// Throws a [ServerException] for all error cases.
  Future<PrivacyPolicyModel> getLatestPolicy();
}

