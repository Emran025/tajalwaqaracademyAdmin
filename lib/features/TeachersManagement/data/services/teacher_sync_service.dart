
//    +----------------+      +----------------+      +---------------------+
//    |   UI (Screen)  |----->|   BLoC/Cubit   |----->| TeacherRepository   |
//    | (Presents data)|      | (Handles state)|      | (Public API for     |
//    +----------------+      +----------------+      |  data access)       |
//                                                    +----------+----------+
//                                                               | (Delegates to)
//                                                               |
//                                                               v
//                     +---------------------+      +------------+-------------+
//                     | WorkManager Plugin  |----->|      Sync Service        |
//                     | (Background Trigger)|      | (The Sync Engine)        |
//                     +---------------------+      +-------------+------------+
//                                                                | (Reads/Writes)
//                                                                |
//                                     +--------------------------+--------------------------+
//                                     |                                                     |
//                                     v                                                     v
//                     +------------------------+      +--------------------------+      +------------------------+
//                     | TeacherRemoteDataSource|<---- |      Sync Queue (DB)     |----->| TeacherLocalDataSource |
//                     | (Fetches/Pushes Deltas)|      | (Tracks local changes)   |      | (Single Source of Truth)|
//                     +------------------------+      +--------------------------+      +------------------------+



/// Defines the abstract contract for the teacher data synchronization engine.
///
/// This service is responsible for orchestrating the complex two-way, delta-based
/// synchronization process between the local database and the remote server.
abstract interface class TeacherSyncService {
  /// Executes the full two-way synchronization process.
  ///
  /// This is typically a "fire-and-forget" operation that runs in the
  /// background. It should handle its own error logging and state management
  /// (e.g., preventing concurrent runs).
  Future<void> performSync({int initialPage = 1});
}