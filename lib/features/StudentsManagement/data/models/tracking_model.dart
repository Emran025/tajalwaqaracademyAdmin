import 'package:flutter/foundation.dart';
import '../../../../core/models/attendance_type.dart';
import 'tracking_detail_model.dart';
import '../../domain/entities/tracking_entity.dart';

/// The data model for a student's daily tracking record.
///
/// This immutable class encapsulates the main tracking entry for a day, along with
/// a list of its detailed components ([TrackingDetailModel]). It handles parsing
/// the nested JSON structure from the API and converting it to a domain-layer
/// [TrackingEntity].

@immutable
final class TrackingModel {
  final int id;
  final String date;
  final int enrollmentId;
  final String note;
  final AttendanceType attendanceTypeId;
  final int behaviorNote;
  final String status;
  final String createdAt;
  final String updatedAt;

  /// A list of detailed tracking items associated with this daily record.
  final List<TrackingDetailModel> details;

  const TrackingModel({
    required this.id,
    required this.date,
    required this.enrollmentId,
    required this.note,
    required this.details,
    required this.attendanceTypeId,
    required this.behaviorNote,
    this.status = 'draft',
    required this.createdAt,
    required this.updatedAt,
  });

  /// A factory for creating a [TrackingModel] from a JSON map.
  /// It robustly handles the parsing of the nested 'details' list.
  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    final detailsListJson = json['details'] as List<dynamic>? ?? [];
    final detailsList = detailsListJson
        .map(
          (detailJson) =>
              TrackingDetailModel.fromJson(detailJson as Map<String, dynamic>),
        )
        .toList();

    return TrackingModel(
      id: json['id'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      enrollmentId: json['enrollmentId'] as int? ?? 0,
      note: json['note'] as String? ?? '',
      attendanceTypeId: detailsList.isEmpty
          ? AttendanceType.absent
          : AttendanceType.present,
      behaviorNote: json['behaviorNote'] as int? ?? 0,
      status: 'completed',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      details: detailsList,
    );
  }

  /// Creates a [TrackingModel] from a database map.
  /// The `details` list is populated separately.
  factory TrackingModel.fromMap(
    Map<String, dynamic> map,
    List<TrackingDetailModel> details,
  ) {
    return TrackingModel(
      // The local 'uuid' column stores the server's integer ID as a string.
      id: int.tryParse(map['uuid'] as String? ?? '0') ?? 0,
      date: map['trackDate'] as String? ?? '',
      enrollmentId: map['enrollmentId'] as int? ?? 0,
      note: map['note'] as String? ?? '',
      attendanceTypeId: AttendanceType.fromId(
        map['attendanceTypeId'] as int? ?? 1,
      ),
      behaviorNote: map['behaviorNote'] as int? ?? 2,
      status: map['status'] as String? ?? 'draft',
      createdAt: (DateTime.fromMicrosecondsSinceEpoch(
        map['createdAt'] as int? ?? 0,
      )).toString(),
      updatedAt: (DateTime.fromMicrosecondsSinceEpoch(
        map['lastModified'] as int? ?? 0,
      )).toString(),
      details: details,
    );
  }

  /// A factory for creating a JSON Map from a [TrackingModel].
  /// This is used for sending data to the server.
  Map<String, dynamic> toJson() {
    return {
      // The 'id' is the local UUID, not the server ID.
      'id': id,
      'date': date,
      'note': note,
      'attendanceTypeId': attendanceTypeId.id,
      'behaviorNote': behaviorNote,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
      // The 'details' key contains an array of detailed tracking items.
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }

  /// Converts the model to a map suitable for the `daily_tracking` table.
  /// Requires the `enrollmentId` foreign key. Note this map does NOT include the details.
  Map<String, dynamic> toMap(int enrollmentId) {
    return {
      // BEST PRACTICE: Convert the integer ID to a string to match the 'TEXT' schema.
      'uuid': id.toString(),
      'enrollmentId': enrollmentId,
      'trackDate': date,
      'note': note,
      'attendanceTypeId': attendanceTypeId.id,
      'behaviorNote': behaviorNote,
      'status': status,
      'createdAt ': (DateTime.tryParse(createdAt) ?? DateTime.now())
          .millisecondsSinceEpoch,
      'lastModified': (DateTime.tryParse(updatedAt) ?? DateTime.now())
          .millisecondsSinceEpoch,
    };
  }

  /// Converts this data model into a domain [TrackingEntity].
  TrackingEntity toEntity() {
    return TrackingEntity(
      id: id.toString(),
      date: DateTime.tryParse(date) ?? DateTime.now(),
      note: note,
      enrollmentId: enrollmentId,
      attendanceTypeId: attendanceTypeId,
      behaviorNote: behaviorNote,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
      details: details.map((detailModel) => detailModel.toEntity()).toList(),
    );
  }

  factory TrackingModel.fromEntity(TrackingEntity entity) {
    return TrackingModel(
      id: int.tryParse(entity.id) ?? 0,
      date: entity.date.toIso8601String(),
      enrollmentId: entity.enrollmentId,
      note: entity.note,
      attendanceTypeId: entity.attendanceTypeId,
      behaviorNote: entity.behaviorNote,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      details: entity.details
          .map((detailEntity) => TrackingDetailModel.fromEntity(detailEntity))
          .toList(),
    );
  }

  factory TrackingModel.fromCsvRow(
    Map<String, dynamic> row,
    List<TrackingDetailModel> details,
  ) {
    return TrackingModel(
      id: row['trackingId'] as int,
      date: row['date'] as String,
      note: row['note'] as String? ?? '',
      enrollmentId: row['note'] as int? ?? 0,
      attendanceTypeId: AttendanceType.values.firstWhere(
        (e) => e.toString() == row['attendance'] as String,
      ),
      behaviorNote: int.tryParse(row['behaviorNote'] as String? ?? '0') ?? 0,
      createdAt: row['createdAt'] as String,
      updatedAt: row['updatedAt'] as String,
      details: details,
    );
  }
}
