/// Defines the abstract contract for a service that handles push notifications.
///
/// This abstraction decouples the application from any specific push notification
/// provider (e.g., Firebase, OneSignal). Implementations of this interface
/// are responsible for initializing the service and retrieving the device's
/// unique push notification token.
abstract interface class PushNotificationService {
  /// Asynchronously retrieves the unique push notification token for this device.
  ///
  /// Returns the token as a [String], or a specific message if a token
  /// cannot be obtained.
  Future<String> getPushToken();
}