import 'package:flutter/foundation.dart';
import 'package:tajalwaqaracademy/core/models/mistake_type.dart'; // Your enhanced enum
import 'package:uuid/uuid.dart';

import '../../domain/entities/mistake.dart';

/// The data model for a single mistake record.
///
/// This immutable class is responsible for:
/// 1. Converting raw database maps into a structured object (`fromDbMap`).
/// 2. Converting the object into a map suitable for database insertion/updates (`toDbMap`).
/// 3. Converting itself into a pure, domain-layer [Mistake] entity (`toEntity`).
@immutable
class MistakeModel {
  // Use local int ID for database relations, and String UUID for sync/identity
  final int localId;
  final String uuid;
  final String trackingDetailId; // Local ID of the parent daily_tracking_detail
  final int ayahIdQuran;
  final int wordIndex;
  final MistakeType mistakeType;
  final int lastModified;

  const MistakeModel({
    required this.localId,
    required this.uuid,
    required this.trackingDetailId,
    required this.ayahIdQuran,
    required this.wordIndex,
    required this.mistakeType,
    required this.lastModified,
  });

  /// A factory for  creating a [MistakeModel] from a json map.
  factory MistakeModel.fromJson(Map<String, dynamic> json) {
    return MistakeModel(
      localId: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      trackingDetailId: (json['trackingDetailId']  as int? ?? 0).toString(),
      ayahIdQuran: json['ayahId_quran'] as int? ?? 0,
      wordIndex: json['wordIndex'] as int? ?? 0,
      mistakeType: MistakeType.fromId(json['mistakeTypeId'] as int? ?? 0),
      lastModified: json['lastModified'] as int? ?? 0,
    );
  }

  /// A factory for creating a [MistakeModel] from a database map.
  factory MistakeModel.fromDbMap(Map<String, dynamic> map) {
    return MistakeModel(
      localId: map['id'] as int? ?? 0,
      uuid: map['uuid'] as String? ?? '',
      trackingDetailId:( map['trackingDetailId'] as int? ?? 0).toString(),
      ayahIdQuran: map['ayahId_quran'] as int? ?? 0,
      wordIndex: map['wordIndex'] as int? ?? 0,
      mistakeType: MistakeType.fromId(map['mistakeTypeId'] as int? ?? 0),
      lastModified: map['lastModified'] as int? ?? 0,
    );
  }

  /// Converts the model to a Json for the `mistakes` in to remote Data source.
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid.isEmpty ? const Uuid().v4() : uuid,
      'trackingDetailId': trackingDetailId,
      'ayahId_quran': ayahIdQuran,
      'wordIndex': wordIndex,
      'mistakeTypeId': mistakeType.id,
      'lastModified': lastModified,
    };
  }

  /// Converts the model to a map suitable for the `mistakes` table.
  ///
  /// Requires the `parentDetailId` (the local integer ID of the parent `daily_tracking_detail` record)
  /// to establish the foreign key relationship.
  Map<String, dynamic> toDbMap(int parentDetailId) {
    return {
      'uuid': uuid.isEmpty ? const Uuid().v4() : uuid,
      'trackingDetailId': parentDetailId,
      'ayahId_quran': ayahIdQuran,
      'wordIndex': wordIndex,
      'mistakeTypeId': mistakeType.id,
      'lastModified': DateTime.now().millisecondsSinceEpoch,
      'isDeleted': 0, // Default to not deleted
    };
  }

  /// Converts this data model into a domain [Mistake] entity.
  Mistake toEntity() {
    // Note: The entity uses the UUID for its `id` and `trackingDetailId` for consistency.
    // We would need to fetch the parent detail's UUID if we want to be perfectly clean,
    // but for now, passing the local ID as a string is a pragmatic approach.
    // Let's assume the parent UUID is fetched and available when converting.

    // For a truly clean conversion, the repository would fetch the parent detail's UUID.
    // However, since this `toEntity` is called within the context of an already-fetched
    // detail, we can assume the parent UUID is known.

    // This conversion is simplified as the BLoC primarily deals with the model's properties.
    return Mistake(
      id: uuid,
      // This would ideally be the UUID of the parent detail, not the local ID.
      // This is a point of coupling that can be improved if needed.
      trackingDetailId: trackingDetailId.toString(),
      ayahIdQuran: ayahIdQuran,
      wordIndex: wordIndex,
      mistakeType: mistakeType,
    );
  }

  /// Creates a [MistakeModel] from a from Entity mistake.
  factory MistakeModel.fromEntity(Mistake entity) {
    return MistakeModel(
      localId:
          0, // Local ID is not set here, it will be assigned by the database
      uuid: entity.id,
      trackingDetailId: entity.trackingDetailId,
      // Assuming it's a string ID
      ayahIdQuran: entity.ayahIdQuran,
      wordIndex: entity.wordIndex,
      mistakeType: entity.mistakeType,
      lastModified:
          DateTime.now().millisecondsSinceEpoch, // Set to current time
    );
  }

  /// Creates a copy of this model but with the given fields replaced with the new values.
  MistakeModel copyWith({
    int? localId,
    String? uuid,
    String? trackingDetailId,
    int? ayahIdQuran,
    int? wordIndex,
    MistakeType? mistakeType,
    int? lastModified,
  }) {
    return MistakeModel(
      localId: localId ?? this.localId,
      uuid: uuid ?? this.uuid,
      trackingDetailId: trackingDetailId ?? this.trackingDetailId,
      ayahIdQuran: ayahIdQuran ?? this.ayahIdQuran,
      wordIndex: wordIndex ?? this.wordIndex,
      mistakeType: mistakeType ?? this.mistakeType,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
