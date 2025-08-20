
import 'package:flutter/material.dart';

import '../../../../core/models/pagination_info_model.dart';
import 'teacher_model.dart'; // Assuming you have a PaginationInfo model here

/// Represents the structured response from the teacher synchronization endpoint.
///
/// This model is responsible for parsing the entire paginated API response.
/// It intelligently separates the incoming records into two lists:
/// - `updated`: Records to be created or updated locally.
/// - `deleted`: Records to be marked as deleted locally.
/// It also extracts crucial pagination and timestamp metadata for the sync engine.
@immutable
final class TeacherSyncResponseModel {
  /// A list of teacher models that were created or updated on the server.
  final List<TeacherModel> updated;

  /// A list of teacher models that were marked as deleted on the server.
  final List<TeacherModel> deleted;

  /// The new timestamp provided by the server to be used for the next sync cycle.
  final int newSyncTimestamp;
  
  /// Pagination details from the API response.
  final PaginationInfo paginationInfo;

  const TeacherSyncResponseModel({
    required this.updated,
    required this.deleted,
    required this.newSyncTimestamp,
    required this.paginationInfo,
  });

  /// A smart factory for creating a [TeacherSyncResponseModel] from a raw JSON map.
  factory TeacherSyncResponseModel.fromJson(Map<String, dynamic> json) {
    // 1. Safely parse the list of all records from the 'data' key.
    final allTeachersData = json['data'] as List<dynamic>? ?? [];
    final allTeacherModels = allTeachersData
        .map((item) => TeacherModel.fromJson(item as Map<String, dynamic>))
        .toList();

    // 2. Intelligently partition the list into 'updated' and 'deleted'
    //    based on the `isDeleted` flag.
    final List<TeacherModel> updatedList = [];
    final List<TeacherModel> deletedList = [];
    for (final teacher in allTeacherModels) {
      if (teacher.isDeleted) {
        deletedList.add(teacher);
      } else {
        updatedList.add(teacher);
      }
    }

    // 3. Extract the new sync timestamp from the response.
    //    A robust implementation would get this from a specific field in the response.
    //    Here we'll use the current time as a fallback.
    final timestamp = json['meta']?['server_timestamp'] as int? ??
                      DateTime.now().millisecondsSinceEpoch;

    // 4. Parse pagination info.
    final pagination = PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>? ?? {});

    return TeacherSyncResponseModel(
      updated: updatedList,
      deleted: deletedList,
      newSyncTimestamp: timestamp,
      paginationInfo: pagination,
    );
  }
}