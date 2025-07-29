
/// Defines the abstract contract for a client that consumes a remote API.
///
/// This abstraction is the cornerstone of the data layer's networking stack.
/// It decouples the application from any specific HTTP client implementation
/// (e.g., Dio, http), enabling modularity and testability. Any class that
/// handles API communication MUST implement this interface.
abstract interface class ApiConsumer {
  /// Executes a GET request to the given [path].
  ///
  /// - [path]: The resource path, appended to the base URL.
  /// - [data]: An optional request payload.
  /// - [queryParameters]: A map of key-value pairs to be appended as query
  ///   strings to the URL.
  ///
  /// Returns a [Future] which completes with the decoded response body.
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  });

  /// Executes a POST request to the given [path].
  ///
  /// - [path]: The resource path.
  /// - [data]: The request payload.
  /// - [queryParameters]: Optional URL query parameters.
  /// - [isFormData]: If `true`, the [data] is sent as `multipart/form-data`,
  ///   typically used for file uploads.
  ///
  /// Returns a [Future] which completes with the decoded response body.
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  });

  /// Executes a PATCH request for partial resource updates at the given [path].
  ///
  /// - [path]: The resource path.
  /// - [data]: The request payload containing the fields to be updated.
  /// - [queryParameters]: Optional URL query parameters.
  /// - [isFormData]: If `true`, the [data] is sent as `multipart/form-data`.
  ///
  /// Returns a [Future] which completes with the decoded response body.
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  });

  /// Executes a DELETE request to the given [path].
  ///
  /// - [path]: The path of the resource to be deleted.
  ///
  /// Returns a [Future] which completes with the decoded response body, which
  /// might be empty or contain a confirmation message.
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  });
}