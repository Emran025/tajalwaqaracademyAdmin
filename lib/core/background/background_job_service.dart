/// Defines the abstract contract for a service that initializes and schedules
/// all background jobs for the application.
abstract interface class BackgroundJobService {
  /// Initializes the background job scheduler and registers all necessary tasks.
  /// This should be called once at application startup.
  Future<void> initialize();
}