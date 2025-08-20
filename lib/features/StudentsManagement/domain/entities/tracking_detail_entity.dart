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
}
