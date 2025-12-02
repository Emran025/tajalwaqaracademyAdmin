import '../../../../core/models/attendance_type.dart';
import 'tracking_detail_entity.dart';
import 'package:flutter/material.dart';

@immutable
class TrackingEntity {
  final String id;
  final DateTime date;
  final String note;
  final  AttendanceType attendanceTypeId;
  final int behaviorNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// A list of detailed tracking items associated with this daily record.
  final List<TrackingDetailEntity> details;

 const TrackingEntity({
    required this.id,
    required this.date,
    required this.note,
    required this.attendanceTypeId,
    required this.behaviorNote,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'note': note,
      'attendanceTypeId': attendanceTypeId.toString(),
      'behaviorNote': behaviorNote,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'details': details.map((d) => d.toJson()).toList(),
    };
  }

  factory TrackingEntity.fromJson(Map<String, dynamic> json) {
    return TrackingEntity(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String,
      attendanceTypeId: AttendanceType.values.firstWhere(
          (e) => e.toString() == json['attendanceTypeId'] as String),
      behaviorNote: json['behaviorNote'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      details: (json['details'] as List<dynamic>)
          .map((d) =>
              TrackingDetailEntity.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  factory TrackingEntity.fromCsvRow(Map<String, dynamic> row, List<TrackingDetailEntity> details) {
    return TrackingEntity(
      id: row['trackingId'] as String,
      date: DateTime.parse(row['date'] as String),
      note: row['note'] as String? ?? '',
      attendanceTypeId: AttendanceType.values
          .firstWhere((e) => e.toString() == row['attendance'] as String),
      behaviorNote: int.tryParse(row['behaviorNote'] as String? ?? '0') ?? 0,
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: DateTime.parse(row['updatedAt'] as String),
      details: details,
    );
  }
}
