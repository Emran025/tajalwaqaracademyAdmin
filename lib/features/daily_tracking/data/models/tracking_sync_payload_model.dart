
//lib/features/daily_tracking/data/models/tracking_sync_payload_model.dart
import 'package:flutter/foundation.dart';
// Import the main model that will be sent
import 'package:tajalwaqaracademy/features/StudentsManagement/data/models/tracking_model.dart';

/// Represents the payload for synchronizing local tracking updates to the server.
///
/// This model encapsulates a list of `TrackingModel` objects that have been
/// created or updated locally and need to be pushed to the remote backend.
@immutable
class TrackingSyncPayloadModel {
  /// A list of tracking records that have been created or updated locally.
  final List<TrackingModel> updated;

  const TrackingSyncPayloadModel({
    required this.updated,
  });

  /// Serializes this payload object into a JSON map.
  ///
  /// The structure is designed to be easily parsed by the server-side API.
  Map<String, dynamic> toJson() {
    return {
      // The key 'updated' contains an array of tracking objects.
      'updated': updated.map((trackingModel) => trackingModel.toJson()).toList(),
    };
  }
}