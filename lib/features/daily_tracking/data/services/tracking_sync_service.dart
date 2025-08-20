/// Defines the abstract contract for the tracking data synchronization engine.
///
/// This service is responsible for orchestrating the PUSH-based synchronization
/// process, sending local tracking changes to the remote server.
abstract interface class TrackingSyncService {
  /// Executes the PUSH synchronization process for pending tracking updates.
  ///
  /// This is typically a "fire-and-forget" operation that runs in the
  /// background. It handles its own error logging and state management
  /// (e.g., preventing concurrent runs). It will only proceed if there is
  /// an active internet connection.
  Future<void> performSync();
}