import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/api/api_consumer.dart';
import 'package:tajalwaqaracademy/core/api/end_ponits.dart';
import '../../domain/entities/paginated_teachers_result.dart';
import '../models/teacher_model.dart';
import '../models/teacher_sync_response_model.dart';
import 'teacher_remote_data_source.dart';

/// The concrete implementation of [TeacherRemoteDataSource].
///
/// This class communicates with the remote API using the provided [ApiConsumer].
/// Its primary responsibilities are to format request data, call the appropriate
/// API endpoints, and parse the raw JSON responses into strongly-typed data models.
/// It relies on the [ApiConsumer] to handle underlying network errors and exceptions.

/// to perform all teacher-related data operations, including the complex
/// two-way synchronization logic.
@LazySingleton(as: TeacherRemoteDataSource)
final class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final ApiConsumer _apiConsumer;

  TeacherRemoteDataSourceImpl({required ApiConsumer apiConsumer})
    : _apiConsumer = apiConsumer;
  @override
  Future<PaginatedTeachersResult> getTeachers({required int page}) async {
    // Make the API call using the injected ApiConsumer.
    // The ApiConsumer is responsible for handling network exceptions.
    final responseJson = await _apiConsumer.get(
      EndPoint.teachers, // Example: '/teachers'
      queryParameters: {'page': page},
    );

    // The response structure from a paginated endpoint often looks like:
    // {
    //   "data": [...],
    //   "meta": { "last_page": 20 }
    // }
    // We need to parse this structure robustly.

    // Ensure the response is a map, otherwise it's an invalid format.
    if (responseJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid response format: Expected a map.');
    }

    // Safely extract the list of teacher data.
    final List<dynamic> teachersListJson =
        responseJson['data'] as List<dynamic>? ?? [];

    // Parse each item in the list into a TeacherModel.
    final List<TeacherModel> teachers = teachersListJson
        .map(
          (teacherJson) =>
              TeacherModel.fromJson(teacherJson as Map<String, dynamic>),
        )
        .toList();

    // Safely extract pagination metadata.
    final int currentPage =
        responseJson['meta']?['current_page'] as int? ?? page;
    final int lastPage =
        responseJson['meta']?['last_page'] as int? ?? currentPage;

    // Construct and return the final paginated result.
    return PaginatedTeachersResult(
      teachers: teachers,
      hasMorePages: currentPage < lastPage,
    );
  }

  @override
  Future<TeacherSyncResponseModel> getUpdatedTeachers({
    required int since,
    required int page,
  }) async {
    // The `since` timestamp is sent as a query parameter to the sync endpoint.
    // The server is expected to return only the records that have changed since then.
    final responseJson = await _apiConsumer.get(
      EndPoint.teachersSync, // Example: '/teachers/sync'
      queryParameters: {
        'updatedSince': since,
        'page': page,
      }, // Assuming page 1 for simplicity
    );

    // The response is expected to be a map containing 'updated' and 'deleted' lists.
    if (responseJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid sync response format: Expected a root map.',
      );
    }

    // Delegate parsing to the dedicated response model.
    return TeacherSyncResponseModel.fromJson(responseJson);
  }

  @override
  Future<TeacherModel> upsertTeacher(Map<String, dynamic> teacherData) async {
    // The API should handle both create (if no ID) and update (if ID exists)
    // with a single endpoint for simplicity.
    final responseJson = await _apiConsumer.post(
      EndPoint.teachersUpsert, // Example: '/teachers/upsert'
      data: teacherData,
    );

    if (responseJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid upsert response format: Expected a teacher object map.',
      );
    }

    // The server returns the final state of the object, which we parse and return.
    return TeacherModel.fromJson(responseJson);
  }

  @override
  Future<void> deleteTeacher(String teacherId) async {
    // A DELETE request is sent to a URL that includes the teacher's ID.
    await _apiConsumer.delete(
      '${EndPoint.teachers}/$teacherId', // Example: DELETE /teachers/some-uuid
    );
    // On a successful 2xx response, we expect no content, so the method returns void.
  }
}
