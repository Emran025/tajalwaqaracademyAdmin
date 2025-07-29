import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/api/api_consumer.dart';
import 'package:tajalwaqaracademy/core/api/end_ponits.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/data/models/student_model.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/data/models/student_sync_response_model.dart';
import '../../domain/entities/paginated_students_result.dart';
import 'student_remote_data_source.dart';

/// The concrete implementation of [StudentRemoteDataSource].
///
/// This class communicates with the remote API using the provided [ApiConsumer].
/// Its primary responsibilities are to format request data, call the appropriate
/// API endpoints, and parse the raw JSON responses into strongly-typed data models.
/// It relies on the [ApiConsumer] to handle underlying network errors and exceptions.

/// to perform all student-related data operations, including the complex
/// two-way synchronization logic.
@LazySingleton(as: StudentRemoteDataSource)
final class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final ApiConsumer _apiConsumer;

  StudentRemoteDataSourceImpl({required ApiConsumer apiConsumer})
    : _apiConsumer = apiConsumer;
  @override
  Future<PaginatedStudentsResult> getStudents({required int page}) async {
    // Make the API call using the injected ApiConsumer.
    // The ApiConsumer is responsible for handling network exceptions.
    final responseJson = await _apiConsumer.get(
      EndPoint.students, // Example: '/students'
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

    // Safely extract the list of student data.
    final List<dynamic> studentsListJson =
        responseJson['data'] as List<dynamic>? ?? [];

    // Parse each item in the list into a StudentModel.
    final List<StudentModel> students = studentsListJson
        .map(
          (studentJson) =>
              StudentModel.fromJson(studentJson as Map<String, dynamic>),
        )
        .toList();

    // Safely extract pagination metadata.
    final int currentPage =
        responseJson['meta']?['current_page'] as int? ?? page;
    final int lastPage =
        responseJson['meta']?['last_page'] as int? ?? currentPage;

    // Construct and return the final paginated result.
    return PaginatedStudentsResult(
      students: students,
      hasMorePages: currentPage < lastPage,
    );
  }

  @override
  Future<StudentSyncResponseModel> getUpdatedStudents({
    required int since,
    required int page,
  }) async {
    // The `since` timestamp is sent as a query parameter to the sync endpoint.
    // The server is expected to return only the records that have changed since then.
    final responseJson = await _apiConsumer.get(
      EndPoint.studentsSync, // Example: '/students/sync'
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
    return StudentSyncResponseModel.fromJson(responseJson);
  }

  @override
  Future<StudentModel> upsertStudent(Map<String, dynamic> studentData) async {
    // The API should handle both create (if no ID) and update (if ID exists)
    // with a single endpoint for simplicity.
    final responseJson = await _apiConsumer.post(
      EndPoint.studentsUpsert, // Example: '/students/upsert'
      data: studentData,
    );

    if (responseJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid upsert response format: Expected a student object map.',
      );
    }

    // The server returns the final state of the object, which we parse and return.
    return StudentModel.fromJson(responseJson);
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    // A DELETE request is sent to a URL that includes the student's ID.
    await _apiConsumer.delete(
      '${EndPoint.students}/$studentId', // Example: DELETE /students/some-uuid
    );
    // On a successful 2xx response, we expect no content, so the method returns void.
  }
}
