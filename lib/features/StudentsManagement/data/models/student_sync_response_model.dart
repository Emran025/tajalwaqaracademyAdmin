import '../../../../core/models/pagination_info_model.dart';
import 'student_info_model.dart'; // Assuming you have a PaginationInfo model here

/// Represents the structured response from the student synchronization endpoint.
///
/// This model is responsible for parsing the entire paginated API response.
/// It intelligently separates the incoming records into two lists:
/// - `updated`: Records to be created or updated locally.
/// - `deleted`: Records to be marked as deleted locally.
/// It also extracts crucial pagination and timestamp metadata for the sync engine.

final class StudentSyncResponseModel {
  /// A list of student models that were created or updated on the server.
  final List<StudentInfoModel> updated;

  /// A list of student models that were marked as deleted on the server.
  final List<StudentInfoModel> deleted;

  /// The new timestamp provided by the server to be used for the next sync cycle.
  final int newSyncTimestamp;

  /// Pagination details from the API response.
  final PaginationInfo paginationInfo;

  const StudentSyncResponseModel({
    required this.updated,
    required this.deleted,
    required this.newSyncTimestamp,
    required this.paginationInfo,
  });

  /// A smart factory for creating a [StudentSyncResponseModel] from a raw JSON map.
  factory StudentSyncResponseModel.fromJson(Map<String, dynamic> json) {
    // 1. Safely parse the list of all records from the 'data' key.
    final allStudentsData = json['data'] as List<dynamic>? ?? [];
    final allStudentModels = allStudentsData
        .map((item) => StudentInfoModel.fromJson(item as Map<String, dynamic>))
        .toList();

    // 2. Intelligently partition the list into 'updated' and 'deleted'
    //    based on the `isDeleted` flag.
    final List<StudentInfoModel> updatedList = [];
    final List<StudentInfoModel> deletedList = [];
    for (final student in allStudentModels) {
      if (student.studentModel.isDeleted) {
        deletedList.add(student);
      } else {
        updatedList.add(student);
      }
    }

    // 3. Extract the new sync timestamp from the response.
    //    A robust implementation would get this from a specific field in the response.
    //    Here we'll use the current time as a fallback.
    final timestamp =
        json['meta']?['server_timestamp'] as int? ??
        DateTime.now().millisecondsSinceEpoch;

    // 4. Parse pagination info.
    final pagination = PaginationInfo.fromJson(
      json['pagination'] as Map<String, dynamic>? ?? {},
    );

    return StudentSyncResponseModel(
      updated: updatedList,
      deleted: deletedList,
      newSyncTimestamp: timestamp,
      paginationInfo: pagination,
    );
  }
}
