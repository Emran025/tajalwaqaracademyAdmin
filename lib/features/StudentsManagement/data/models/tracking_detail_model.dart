import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../../domain/entities/tracking_detail_entity.dart';
import 'package:tajalwaqaracademy/core/constants/tracking_unit_detail.dart';
import 'package:tajalwaqaracademy/core/models/tracking_type.dart';

import 'package:tajalwaqaracademy/features/daily_tracking/data/models/mistake_model.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/entities/tracking_unit.dart';

/// The data model for the detailed breakdown of a daily tracking record.
///
/// This immutable class represents a single tracking item (e.g., memorization,
/// review) for a specific day. It is responsible for parsing JSON and converting
/// to a domain-layer [TrackingDetailEntity].
@immutable
final class TrackingDetailModel {
  final int id; // The local auto-incremented ID
  final String uuid; // The sync-ready unique ID
  final int trackingId; // The local ID of the parent daily_tracking record
  final TrackingType trackingTypeId;
  final TrackingUnitDetail fromTrackingUnitId;
  final TrackingUnitDetail toTrackingUnitId;
  final int actualAmount;
  final String comment;
  final int score;
  final double gap;
  final String status;

  // 2. Add the list of mistakes to the model
  final List<MistakeModel> mistakes;

  final String createdAt;
  final String updatedAt;

  const TrackingDetailModel({
    required this.id,
    required this.uuid,
    required this.trackingId,
    required this.trackingTypeId,
    required this.fromTrackingUnitId,
    required this.toTrackingUnitId,
    required this.actualAmount,
    required this.comment,
    required this.score,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.mistakes = const [], // 3. Add to the constructor with a default value
    this.gap = 0.0,
  });

  /// A factory for creating a [TrackingDetailModel] from a JSON map.
  /// Note: Mistakes are typically not loaded from the same top-level JSON.
  /// They are loaded separately and associated later.
  factory TrackingDetailModel.fromJson(Map<String, dynamic> json) {
    final mistakesListJson = json['mistakes'] as List<dynamic>? ?? [];
    final mistakesList = mistakesListJson
        .map(
          (mistakeJson) =>
              MistakeModel.fromJson(mistakeJson as Map<String, dynamic>),
        )
        .toList();
    return TrackingDetailModel(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      trackingId: json['trackingId'] as int? ?? 0,
      trackingTypeId: TrackingType.fromId(json['trackingTypeId'] as int? ?? 0),
      fromTrackingUnitId:
          trackingUnitDetail[(json['fromTrackingUnitId'] as int? ?? 0) - 1],
      toTrackingUnitId:
          trackingUnitDetail[(json['toTrackingUnitId'] as int? ?? 0) - 1],
      actualAmount: json['actualAmount'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      status: 'completed',
      score: json['score'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      // Mistakes are loaded separately, so we initialize with an empty list.
      mistakes: mistakesList,
    );
  }

  /// A factory for creating a [TrackingDetailModel] from a Db Map.
  /// 4. Update fromMap to accept the associated mistakes list.
  factory TrackingDetailModel.fromMap(
    Map<String, dynamic> map,
    List<MistakeModel> mistakes,
  ) {
    return TrackingDetailModel(
      id: map['id'] as int? ?? 0,
      uuid: map['uuid'] as String? ?? '',
      trackingId: map['trackingId'] as int? ?? 0,
      trackingTypeId: TrackingType.fromId(map['typeId'] as int? ?? 0),
      actualAmount: map['actualAmount'] as int? ?? 0,
      fromTrackingUnitId:
          trackingUnitDetail[(map['fromTrackingUnitId'] as int? ?? 1) - 1],
      toTrackingUnitId:
          trackingUnitDetail[(map['toTrackingUnitId'] as int? ?? 1) - 1],
      comment: map['comment'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      status: map['status'] as String? ?? 'draft',
      gap: map['gap'] as double? ?? 0,
      createdAt:
          map['createdAt'] as String? ??
          '', // These might not exist in your DB schema
      updatedAt:
          map['updatedAt'] as String? ??
          '', // These might not exist in your DB schema
      mistakes: mistakes, // Assign the passed mistakes list
    );
  }

  /// Converts the model to a JSON map.

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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'mistakes': mistakes.map((m) => m.toJson()).toList(),
    };
  }


  factory TrackingDetailModel.fromCsvRow(Map<String, dynamic> row) {
    final mistakesJson = row['mistakesJson'] as String;
    final mistakes = (jsonDecode(mistakesJson) as List<dynamic>)
        .map((m) => MistakeModel.fromJson(m as Map<String, dynamic>))
        .toList();

    return TrackingDetailModel(
      id: 0,
      uuid: '',
      trackingId: row['trackingId'] as int,
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
      createdAt: row['createdAt'] as String,
      updatedAt: row['updatedAt'] as String,
      mistakes: mistakes,
    );
  }
  /// This map aligns with the schema of the `daily_tracking_detail` table.
  /// NOTE: This does NOT include the mistakes, as they are saved to a separate table.
  Map<String, dynamic> toMap(int parentTrackingId) {
    return {
      'uuid': uuid.isEmpty ? const Uuid().v4() : uuid,
      'trackingId': parentTrackingId,
      'typeId': trackingTypeId.id,
      'actualAmount': actualAmount,
      'fromTrackingUnitId': fromTrackingUnitId.id,
      'toTrackingUnitId': toTrackingUnitId.id,
      'comment': comment,
      'status': status,
      'score': score,
      'gap': gap,
      'lastModified': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// 5. Update copyWith to handle the new mistakes field.
  TrackingDetailModel copyWith({
    int? id,
    String? uuid,
    int? trackingId,
    TrackingType? trackingTypeId,
    TrackingUnitDetail? fromTrackingUnitId,
    TrackingUnitDetail? toTrackingUnitId,
    int? actualAmount,
    String? comment,
    String? status,
    int? score,
    double? gap,
    List<MistakeModel>? mistakes,
    String? createdAt,
    String? updatedAt,
  }) {
    return TrackingDetailModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      trackingId: trackingId ?? this.trackingId,
      trackingTypeId: trackingTypeId ?? this.trackingTypeId,
      fromTrackingUnitId: fromTrackingUnitId ?? this.fromTrackingUnitId,
      toTrackingUnitId: toTrackingUnitId ?? this.toTrackingUnitId,
      comment: comment ?? this.comment,
      actualAmount: actualAmount ?? this.actualAmount,
      score: score ?? this.score,
      status: status ?? this.status,
      gap: gap ?? this.gap,
      mistakes: mistakes ?? this.mistakes, // Handle mistakes in copyWith
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 6. Update toModel to convert the list of mistake models to mistake entities.
  TrackingDetailEntity toEntity() {
    return TrackingDetailEntity(
      id: id, // Use UUID for the entity's ID
      uuid: uuid, // Use UUID for the entity's ID
      trackingId: trackingId.toString(),
      trackingTypeId: trackingTypeId,
      fromTrackingUnitId: fromTrackingUnitId,
      toTrackingUnitId: toTrackingUnitId,
      actualAmount: actualAmount,
      comment: comment,
      status: status,
      score: score,
      gap: gap,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
      // Convert each MistakeModel to its corresponding Mistake entity
      mistakes: mistakes
          .map((mistakeModel) => mistakeModel.toEntity())
          .toList(),
    );
  }

  factory TrackingDetailModel.fromEntity(TrackingDetailEntity entity) {
    final mistakes = entity.mistakes
        .map((mistakeEntity) => MistakeModel.fromEntity(mistakeEntity))
        .toList();
    return TrackingDetailModel(
      id: entity.id, // Handle potential new records
      uuid: entity.uuid,
      trackingId: int.parse(entity.trackingId),
      trackingTypeId: entity.trackingTypeId,
      fromTrackingUnitId: entity.fromTrackingUnitId,
      toTrackingUnitId: entity.toTrackingUnitId,
      actualAmount: entity.actualAmount,
      comment: entity.comment,
      status: entity.status,
      score: entity.score,
      gap: entity.gap,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      mistakes: mistakes,
    );
  }
}
