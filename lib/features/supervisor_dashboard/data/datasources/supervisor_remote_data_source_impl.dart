import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/api/api_consumer.dart';
import 'package:tajalwaqaracademy/core/api/end_ponits.dart';
import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';

import '../models/applicant_model.dart';
import '../models/applicant_profile_model.dart';
import 'supervisor_remote_data_source.dart';

/// The concrete implementation of [SupervisorRemoteDataSource].
///
/// This class communicates with the remote API using the provided [ApiConsumer].
/// Its primary responsibilities are to format request data, call the appropriate
/// API endpoints, and parse the raw JSON responses into strongly-typed data models.
/// It relies on the [ApiConsumer] to handle underlying network errors and exceptions.

/// to perform all student-related data operations, including the complex
/// two-way synchronization logic.
@LazySingleton(as: SupervisorRemoteDataSource)
final class SupervisorRemoteDataSourceImpl
    implements SupervisorRemoteDataSource {
  final ApiConsumer _apiConsumer;

  SupervisorRemoteDataSourceImpl({required ApiConsumer apiConsumer})
    : _apiConsumer = apiConsumer;

  @override
  Future<PaginatedApplicantsResponse> getApplicants({
    int page = 1,
    int? since,
    required UserRole entityType,
  }) async {
    try {
      final responseJson = await _apiConsumer.get(
        EndPoint.studentApplicants.replaceAll(
          '{application_type}',
          entityType.label.toLowerCase(),
        ),
        queryParameters: {
          'page': page,
          if (since != null) 'updated_since': since,
        },
      );

      if (responseJson is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid response format for student applicants',
        );
      }

      return PaginatedApplicantsResponse.fromJson(responseJson);
    } catch (e) {
      CacheException(message: "Undifund Data");
      rethrow;
    }
  }

  @override
  Future<ApplicantProfileModel> getApplicantProfile(int applicantId) async {
    try {
      final responseJson = await _apiConsumer.get(
        EndPoint.applicantProfile.replaceAll('{id}', applicantId.toString()),
      );

      if (responseJson is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid response format for applicant profile',
        );
      }

      return ApplicantProfileModel.fromJson(responseJson['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> approveApplicant(int applicantId) async {
    try {
      await _apiConsumer.post(
        EndPoint.approveApplicant.replaceAll('{id}', applicantId.toString()),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> rejectApplicant(int applicantId, String reason) async {
    try {
      await _apiConsumer.post(
        EndPoint.rejectApplicant.replaceAll('{id}', applicantId.toString()),
        body: {'reason': reason},
      );
    } catch (e) {
      rethrow;
    }
  }
}
