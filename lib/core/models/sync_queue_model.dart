import 'dart:convert';
import 'package:flutter/foundation.dart';

/// The data model for a single operation in the synchronization queue.
///
/// This immutable class represents a local change (create, update, or delete)
/// that is pending synchronization with the remote server. It is created from a
/// database map and provides the [SyncService] with all the necessary information
/// to execute the required API call.
@immutable
final class SyncQueueModel {
  /// The local database ID of this queue entry.
  final int id;

  /// The unique identifier (UUID) of the entity that was modified.
  final String entityUuid;

  /// A string identifying the type of entity (e.g., 'halaqa', 'student').
  final String entityType;

  /// The type of operation performed ('create', 'update', 'delete').
  final String operationType;

  /// A JSON string containing the data payload for 'create' and 'update' operations.
  /// This is null for 'delete' operations.
  final String? payload;

  /// The Unix timestamp (milliseconds) when the operation was queued.
  final int createdAt;

  /// The current status of the operation ('pending', 'in_progress', 'failed').
  final String status;

  const SyncQueueModel({
    required this.id,
    required this.entityUuid,
    required this.entityType,
    required this.operationType,
    this.payload,
    required this.createdAt,
    required this.status,
  });

  /// A factory constructor for creating a new [SyncQueueModel] instance from a database map.
  factory SyncQueueModel.fromMap(Map<String, dynamic> map) {
    return SyncQueueModel(
      id: map['id'] as int,
      entityUuid: map['entity_uuid'] as String,
      entityType: map['entity_type'] as String,
      operationType: map['operation_type'] as String,
      payload: map['payload'] as String?,
      createdAt: map['created_at'] as int,
      status: map['status'] as String,
    );
  }

  /// A convenience getter to decode the JSON payload string into a Map.
  /// Returns `null` if the payload is empty or invalid.
  Map<String, dynamic>? get decodedPayload {
    if (payload == null) return null;
    try {
      return json.decode(payload!) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding sync queue payload for operation ID $id: $e');
      return null;
    }
  }

  // --- Boilerplate code for value equality ---

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SyncQueueModel &&
        other.id == id &&
        other.entityUuid == entityUuid;
  }

  @override
  int get hashCode => id.hashCode ^ entityUuid.hashCode;
}
