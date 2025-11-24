// path: lib/features/settings/data/datasources/settings_remote_data_source_impl.dart

import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/user_profile_entity.dart';

import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_ponits.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/faq_model.dart';
import '../models/privacy_policy_model.dart';
import '../models/support_ticket_model.dart';
import '../models/terms_of_use_model.dart';
import '../models/user_profile_model.dart';
import '../models/user_session_model.dart';
import 'settings_remote_data_source.dart';

/// Implementation of [SettingsRemoteDataSource] using the shared [ApiConsumer].
///
/// This class is responsible for making authenticated API calls to fetch and
/// update user profile information. It relies on the [ApiConsumer] to handle
/// low-level details like adding authentication headers and throwing
/// a [ServerException] on non-2xx responses.
@LazySingleton(as: SettingsRemoteDataSource)
class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiConsumer _api;

  SettingsRemoteDataSourceImpl({required ApiConsumer api}) : _api = api;

  /// Fetches the user profile using a GET request.
  ///
  /// The [ApiConsumer] is expected to throw a [ServerException] if the request
  /// fails (e.g., network error, 4xx/5xx status code).
  @override
  Future<UserProfileModel> getUserProfile() async {
    // Make the API call. If it throws, the exception will propagate up.
    final sessionsResponseJson = await _api.get(EndPoint.sessions);
    // The 'user' object is parsed using the existing UserModel from the Auth feature.
    final activeSessions = (sessionsResponseJson['data'] as List)
        .map((sessionJson) => UserSessionModel.fromJson(sessionJson))
        .toList();
    // Make the API call. If it throws, the exception will propagate up.
    final userResponseJson = await _api.get(EndPoint.userProfile);
    // The 'user' object is parsed using the existing UserModel from the Auth feature.

    final data = userResponseJson['data'] ?? {};
    final user = UserModel.fromJson(
      data['user'] ?? {},
      UserRole.fromLabel(data['role'] ?? 'teacher'),
    );
    // The 'active_sessions' list is parsed by mapping each JSON object
    // to a UserSessionModel.
    // If the code reaches here, the request was successful (status 2xx).
    // The only remaining task is to parse the successful response body.
    return UserProfileModel(activeSessions: activeSessions, user: user);
  }

  /// Updates the user profile using a PUT request.
  ///
  /// The method returns `Future<void>`, indicating that a successful API call
  /// (2xx status) is all that's required for completion.
  @override
  Future<void> updateUserProfile(UserProfileEntity profile) async {
    // The ApiConsumer handles the request. A successful response resolves the
    // Future, while an unsuccessful one throws a ServerException.
    await _api.patch(
      EndPoint.userProfile,
      data: UserProfileModel.fromEntity(profile),
    );
  }

  // =======================================================================
  //                 Privacy Policy Implementation
  // =======================================================================

  /// Fetches the latest privacy policy document from the remote server.
  ///
  /// This method is designed to contact the API endpoint responsible for serving
  /// the application's privacy policy. It encapsulates the logic for the network
  /// request and parsing the response into a structured data model.
  ///
  /// Returns a [PrivacyPolicyModel] on a successful API response.
  /// Throws a [ServerException] if the API call fails for any reason
  /// (e.g., network error, non-2xx status code).
  @override
  Future<PrivacyPolicyModel> getLatestPolicy() async {
    // --- Production Implementation ---
    // The following block contains the final, production-ready code. It is
    // currently commented out to allow for development and testing using
    // placeholder data. To switch to the live API, uncomment this block and
    // remove or comment out the "Placeholder Implementation" block below.

    try {
      // 1. Make the GET request to the designated privacy policy endpoint.
      //    The `ApiConsumer` abstracts away details like authentication headers
      //    and will automatically throw a ServerException for non-2xx responses.
      //    Note: `EndPoint.privacyPolicy` must be defined in your EndPoint constants.

      final responseJson = await _api.get(EndPoint.privacyPolicy);
      // 2. If the request is successful, parse the JSON response.
      //    The `fromJson` factory in the model handles the conversion from a raw
      //    map into a structured `PrivacyPolicyModel` object.
      return PrivacyPolicyModel.fromJson(
        (responseJson as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      // 3. Re-throw any exception from the ApiConsumer or parsing phase.
      //    This ensures that failures are propagated consistently to the
      //    repository layer for proper error handling.
      throw ServerException(message: 'Failed to fetch remote privacy policy.');
    }

    //   // --- Placeholder Implementation (Active for Development) ---
    //   // This block simulates a network call and returns mock data. It is essential
    //   // for enabling parallel development of the UI and business logic without
    //   // depending on a live backend. It provides a predictable data structure
    //   // for building and testing features.

    //   // Simulate network latency to mimic a real-world API call.
    //   await Future.delayed(const Duration(milliseconds: 300));

    //   // A hardcoded mock JSON object that mirrors the exact structure expected
    //   // from the live API. This ensures data consistency.
    // const mockSuccessResponse = {
    //   "version": "2025.08.11",
    //   "lastUpdated": "2025-08-11T14:30:00Z",
    //   "summary": [
    //     "This is a mocked remote policy for development.",
    //     "Your data is handled securely and with respect.",
    //     "You have full control over your data.",
    //   ],
    //   "sections": [
    //     {
    //       "title": "Remote: Introduction (Mocked)",
    //       "content":
    //           "This policy, served from a mock data source, outlines our data principles.",
    //     },
    //     {
    //       "title": "Remote: Data We Collect (Mocked)",
    //       "content":
    //           "During development, we simulate the collection of essential data for functionality.",
    //     },
    //   ],
    //   "changelog":
    //       "This version was served by the active placeholder in the remote data source.",
    //   "requiredConsent": true,
    // };

    //   // Use the same `fromJson` factory that the production code will use.
    //   // This ensures the parsing logic is validated even during development.
    //   return PrivacyPolicyModel.fromJson(mockSuccessResponse);
  }

  @override
  Future<FaqResponseModel> getFaqs(int page) async {
    try {
      final responseJson = await _api.get(
        EndPoint.faqs,
        queryParameters: {'page': page},
      );
      return FaqResponseModel.fromJson(responseJson as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch FAQs.');
    }
  }

  @override
  Future<void> submitSupportTicket(SupportTicketModel ticket) async {
    try {
      await _api.post(
        EndPoint.tickets,
        data: ticket.toJson(),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to submit support ticket.');
    }
  }

  @override
  Future<TermsOfUseModel> getTermsOfUse() async {
    try {
      final responseJson = await _api.get(EndPoint.termsOfUse);
      return TermsOfUseModel.fromJson(
        (responseJson as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch terms of use.');
    }
  }
}
