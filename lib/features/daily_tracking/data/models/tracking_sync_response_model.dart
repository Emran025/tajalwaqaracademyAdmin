import 'package:flutter/foundation.dart';
/// The concrete implementation of [TrackingRemoteDataSource].
/// This class communicates with the remote API using the provided [ApiConsumer].
/// Its primary responsibilities are to format request data, call the appropriate
/// Represents the server's response after a tracking sync operation.
///
/// This model parses the response to confirm the success of the operation
/// and can carry additional information, such as a list of successfully
/// processed UUIDs or a new server timestamp.
@immutable
class TrackingSyncResponseModel {
  /// A message from the server, e.g., "Sync successful".
  final String message;

  /// A list of UUIDs for the tracking records that the server successfully processed.
  /// This is useful for client-side confirmation.
  final List<String> processedUuids;

  const TrackingSyncResponseModel({
    required this.message,
    this.processedUuids = const [],
  });

  /// A factory for creating a [TrackingSyncResponseModel] from a JSON map.
  factory TrackingSyncResponseModel.fromJson(Map<String, dynamic> json) {
    // Safely parse the list of processed UUIDs.
    final processedList = json['processed_uuids'] as List<dynamic>? ?? [];
    final uuids = processedList.map((id) => id.toString()).toList();

    return TrackingSyncResponseModel(
      message: json['message'] as String? ?? 'Operation completed.',
      processedUuids: uuids,
    );
  }
}