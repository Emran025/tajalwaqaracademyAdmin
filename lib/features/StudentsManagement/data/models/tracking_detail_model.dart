import 'package:flutter/foundation.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/tracking_detail_entity.dart';

import '../../../../core/constants/tracking_unit_detail.dart';
import '../../../../core/entities/tracking_unit.dart';
import '../../../../core/models/tracking_type.dart';

/// The data model for the detailed breakdown of a daily tracking record.
///
/// This immutable class represents a single tracking item (e.g., memorization,
/// review) for a specific day. It is responsible for parsing JSON and converting
/// to a domain-layer [TrackingDetailEntity].
@immutable
final class TrackingDetailModel {
  final int id;
  final int trackingId;
  final TrackingType trackingTypeId;
  final TrackingUnitDetail fromTrackingUnitId;
  final TrackingUnitDetail toTrackingUnitId;
  final int actualAmount;
  final String comment;
  final int score;
  final double? gap;
  final String createdAt;
  final String updatedAt;

  const TrackingDetailModel({
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
    this.gap,
  });

  factory TrackingDetailModel.fromJson(Map<String, dynamic> json) {
    return TrackingDetailModel(
      id: json['id'] as int? ?? 0,
      trackingId: json['trackingId'] as int? ?? 0,
      trackingTypeId: TrackingType.fromId(json['trackingTypeId'] as int? ?? 0),
      fromTrackingUnitId:
          trackingUnitDetail[json['fromTrackingUnitId'] as int? ?? 1],
      toTrackingUnitId:
          trackingUnitDetail[json['toTrackingUnitId'] as int? ?? 1],
      actualAmount: json['actualAmount'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  /// A factory for creating a [TrackingDetailModel] from a Db Map.
  factory TrackingDetailModel.fromDbMap(Map<String, dynamic> map) {
    return TrackingDetailModel(
      id: map['id'] as int? ?? 0,
      trackingId: map['trackingId'] as int? ?? 0,
      trackingTypeId: TrackingType.fromId(map['trackingTypeId'] as int? ?? 0),
      fromTrackingUnitId:
          trackingUnitDetail[map['fromTrackingUnitId'] as int? ?? 1],
      toTrackingUnitId:
          trackingUnitDetail[map['toTrackingUnitId'] as int? ?? 1],
      actualAmount: map['actualAmount'] as int? ?? 0,
      comment: map['comment'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      createdAt: map['createdAt'] as String? ?? '',
      updatedAt: map['updatedAt'] as String? ?? '',
    );
  }

  /// Converts the [TrackingDetailModel] into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingId': trackingId,
      'trackingTypeId': trackingTypeId.toString(),
      'fromTrackingUnitId': fromTrackingUnitId.toString(),
      'toTrackingUnitId': toTrackingUnitId.toString(),
      'actualAmount': actualAmount,
      'comment': comment,
      'score': score,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (gap != null) 'gap': gap,
    };
  }

  /// Converts this data model into a domain [TrackingDetailEntity].
  TrackingDetailEntity toEntity() {
    return TrackingDetailEntity(
      id: id.toString(),
      trackingId: trackingId.toString(),
      trackingTypeId: trackingTypeId,
      fromTrackingUnitId: fromTrackingUnitId,
      toTrackingUnitId: toTrackingUnitId,
      actualAmount: actualAmount,
      comment: comment,
      score: score,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
    );
  }
}
