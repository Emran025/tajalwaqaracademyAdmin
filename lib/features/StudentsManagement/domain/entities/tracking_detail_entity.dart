import 'package:tajalwaqaracademy/core/entities/tracking_unit.dart';

import '../../../../core/models/tracking_type.dart';
import 'package:flutter/material.dart';

import '../../../daily_tracking/domain/entities/mistake.dart';

@immutable
class TrackingDetailEntity {
  final int id;
  final String uuid;
  final String trackingId;
  final TrackingType trackingTypeId;
  final TrackingUnitDetail fromTrackingUnitId;
  final TrackingUnitDetail toTrackingUnitId;
  final int actualAmount;
  final String status;
  final String comment;
  final int score;
  final double gap;
  final DateTime createdAt;
  final DateTime updatedAt;

  // This list is specific to the interactive Quran reader UI.
  // It will be populated by the repository based on the 'comment' or a separate table.
  final List<Mistake> mistakes;

  const TrackingDetailEntity({
    required this.id,
    required this.uuid,
    required this.trackingId,
    required this.trackingTypeId,
    required this.fromTrackingUnitId,
    required this.toTrackingUnitId,
    required this.actualAmount,
    required this.comment,
    required this.status,
    required this.score,
    required this.gap,
    required this.createdAt,
    required this.updatedAt,
    this.mistakes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'trackingId': trackingId,
      'trackingTypeId': trackingTypeId.toString(),
      'fromTrackingUnitId': fromTrackingUnitId.toJson(),
      'toTrackingUnitId': toTrackingUnitId.toJson(),
      'actualAmount': actualAmount,
      'comment': comment,
      'status': status,
      'score': score,
      'gap': gap,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'mistakes': mistakes.map((m) => m.toJson()).toList(),
    };
  }

  factory TrackingDetailEntity.fromJson(Map<String, dynamic> json) {
    return TrackingDetailEntity(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      trackingId: json['trackingId'] as String,
      trackingTypeId: TrackingType.values
          .firstWhere((e) => e.toString() == json['trackingTypeId'] as String),
      fromTrackingUnitId: TrackingUnitDetail.fromJson(
          json['fromTrackingUnitId'] as Map<String, dynamic>),
      toTrackingUnitId: TrackingUnitDetail.fromJson(
          json['toTrackingUnitId'] as Map<String, dynamic>),
      actualAmount: json['actualAmount'] as int,
      comment: json['comment'] as String,
      status: json['status'] as String,
      score: json['score'] as int,
      gap: json['gap'] as double,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      mistakes: (json['mistakes'] as List<dynamic>)
          .map((m) => Mistake.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  factory TrackingDetailEntity.fromCsvRow(Map<String, dynamic> row) {
    final mistakesJson = row['mistakesJson'] as String;
    final mistakes = (jsonDecode(mistakesJson) as List<dynamic>)
        .map((m) => Mistake.fromJson(m as Map<String, dynamic>))
        .toList();

    return TrackingDetailEntity(
      id: 0,
      uuid: '',
      trackingId: row['trackingId'] as String,
      trackingTypeId: TrackingType.values
          .firstWhere((e) => e.toString() == row['detailType'] as String),
      fromTrackingUnitId: TrackingUnitDetail(
        0,
        int.tryParse(row['from_unitId'] as String? ?? '0') ?? 0,
        row['from_fromSurah'] as String,
        int.tryParse(row['from_fromPage'] as String? ?? '0') ?? 0,
        int.tryParse(row['from_fromAyah'] as String? ?? '0') ?? 0,
        row['from_toSurah'] as String,
        int.tryParse(row['from_toPage'] as String? ?? '0') ?? 0,
        int.tryParse(row['from_toAyah'] as String? ?? '0') ?? 0,
      ),
      toTrackingUnitId: TrackingUnitDetail(
        0,
        int.tryParse(row['to_unitId'] as String? ?? '0') ?? 0,
        row['to_fromSurah'] as String,
        int.tryParse(row['to_fromPage'] as String? ?? '0') ?? 0,
        int.tryParse(row['to_fromAyah'] as String? ?? '0') ?? 0,
        row['to_toSurah'] as String,
        int.tryParse(row['to_toPage'] as String? ?? '0') ?? 0,
        int.tryParse(row['to_toAyah'] as String? ?? '0') ?? 0,
      ),
      actualAmount: int.tryParse(row['actualAmount'] as String? ?? '0') ?? 0,
      comment: row['comment'] as String? ?? '',
      status: row['status'] as String? ?? '',
      score: int.tryParse(row['performanceScore'] as String? ?? '0') ?? 0,
      gap: double.tryParse(row['gap'] as String? ?? '0.0') ?? 0.0,
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: DateTime.parse(row['updatedAt'] as String),
      mistakes: mistakes,
    );
  }
}
