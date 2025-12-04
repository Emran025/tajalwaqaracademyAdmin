import '../../../../core/models/attendance_type.dart';
import 'tracking_detail_entity.dart';
import 'package:flutter/material.dart';

@immutable
class TrackingEntity {
  final String id;
  final DateTime date;
  final int enrollmentId;
  final String note;
  final AttendanceType attendanceTypeId;
  final int behaviorNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// A list of detailed tracking items associated with this daily record.
  final List<TrackingDetailEntity> details;

  const TrackingEntity({
    required this.id,
    required this.date,
    required this.enrollmentId,
    required this.note,
    required this.attendanceTypeId,
    required this.behaviorNote,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
  });
}
