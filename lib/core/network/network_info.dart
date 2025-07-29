/// Defines the abstract contract for a service that provides network connectivity information.
///
/// This abstraction decouples application components from the concrete implementation
/// of the network-checking logic. It allows for easy mocking in tests and
/// swapping of the underlying library without affecting dependent classes.
/// Any class that needs to check the network status should depend on this interface.
abstract interface class NetworkInfo {
  /// A Future that resolves to `true` if the device has an active internet
  /// connection, and `false` otherwise.
  ///
  /// This getter provides a simple, asynchronous way to query the current
  /// network state.
  Future<bool> get isConnected;
}