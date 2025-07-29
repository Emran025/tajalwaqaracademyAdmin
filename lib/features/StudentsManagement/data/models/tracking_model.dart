import 'package:flutter/foundation.dart';
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
  final int planId;
  final String date;
  final String note;
  final int behaviorNote;
  final String createdAt;
  final String updatedAt;

  /// A list of detailed tracking items associated with this daily record.
  final List<TrackingDetailModel> details;

  const TrackingModel({
    required this.id,
    required this.planId,
    required this.date,
    required this.note,
    required this.details,
    required this.behaviorNote,
    required this.createdAt,
    required this.updatedAt,
  });

  /// A factory for creating a [TrackingModel] from a JSON map.
  /// It robustly handles the parsing of the nested 'details' list.
  factory TrackingModel.fromJson(Map<String, dynamic> json ) {
    // Safely parse the nested list of details.
    final detailsListJson = json['details'] as List<dynamic>? ?? [];
    final detailsList = detailsListJson
        .map(
          (detailJson) =>
              TrackingDetailModel.fromJson(detailJson as Map<String, dynamic>),
        )
        .toList();

    return TrackingModel(
      id: json['id'] as int? ?? 0,
      planId: json['planId'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      note: json['note'] as String? ?? '',
      behaviorNote: json['behaviorNote'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      details: detailsList,
    );
  }

  /// Converts this data model into a domain [TrackingEntity].
  /// The repository will be responsible for assembling this.
  TrackingEntity toEntity() {
    return TrackingEntity(
      id: id.toString(),
      planId: planId.toString(),
      date: DateTime.tryParse(date) ?? DateTime.now(),
      note: note,
      behaviorNote: behaviorNote,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
      // Delegate the conversion of each detail item.
      details: details.map((detailModel) => detailModel.toEntity()).toList(),
    );
  }

  // You would also have `toDbMap` and `fromDbMap` methods here for caching.
  // The `toDbMap` method would NOT include the `details` list. The
  // `LocalDataSource` would be responsible for saving the details to their
  // own table with a foreign key relationship to the main tracking record.
}
