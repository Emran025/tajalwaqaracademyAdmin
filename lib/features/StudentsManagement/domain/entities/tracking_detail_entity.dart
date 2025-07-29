import 'package:tajalwaqaracademy/core/entities/tracking_unit.dart';

import '../../../../core/models/tracking_type.dart';

class TrackingDetailEntity {
  final String id;
  final String trackingId;
  final TrackingType trackingTypeId;
  final TrackingUnitDetail fromTrackingUnitId;
  final TrackingUnitDetail toTrackingUnitId;
  final int actualAmount;
  final String comment;
  final int score;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrackingDetailEntity({
    required this.id,
    required this.trackingId,
    required this.trackingTypeId,
    required this.fromTrackingUnitId,
    required this.toTrackingUnitId,
    required this.actualAmount,
    required this.comment,
    required this.score,
    required this.createdAt,
    required this.updatedAt,
  });
}
