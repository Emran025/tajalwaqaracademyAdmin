import 'dart:async';

import '../../../../core/models/user_role.dart';

/// Defines the abstract contract for the student data synchronization engine.
///
/// This service is responsible for orchestrating the complex two-way, delta-based
/// synchronization process between the local database and the remote server.
abstract interface class TimelineBuilder {
  /// Executes the full two-way synchronization process.
  ///
  /// This is typically a "fire-and-forget" operation that runs in the
  /// background. It should handle its own error logging and state management
  /// (e.g., preventing concurrent runs).
  Future<void> buildAccurateTimeline(UserRole entityType);
  Future<void> buildAccurateCounts();
}
