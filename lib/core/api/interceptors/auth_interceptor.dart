import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tajalwaqaracademy/core/api/end_ponits.dart'; // Required to identify the refresh endpoint

/// A Dio interceptor responsible for automatically injecting the
/// `Authorization` header with a Bearer token into outgoing API requests.
///
/// This interceptor seamlessly integrates into the Dio client's request
/// lifecycle. It fetches the current access token from secure storage and, if
/// available, attaches it to the request headers. This centralizes the
/// authentication logic, ensuring that all relevant API calls are properly
/// authenticated without manual intervention in every data source.
final class AuthInterceptor extends Interceptor {
  /// The secure storage mechanism used to persist and retrieve authentication tokens.
  final FlutterSecureStorage _secureStorage;

  /// Constructs an [AuthInterceptor].
  ///
  /// Requires a [_secureStorage] instance, which will be provided by a
  /// dependency injection container.
  AuthInterceptor({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  /// This method is called by Dio before a request is sent.
  ///
  /// It intercepts the request options, reads the access token, and modifies
  /// the headers accordingly.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Strategically skip token injection for the token refresh endpoint.
    // This is a critical guard to prevent the refresh request itself from
    // being sent with an (potentially expired) access token, which could
    // cause issues or be redundant.
    if (options.path.contains(EndPoint.refreshToken) ||
        options.path.contains(EndPoint.logIn) ||
        options.path.contains(EndPoint.forgetPassword)) {
      return handler.next(options);
    }

    // Attempt to retrieve the access token from secure storage.
    final String? token = await _secureStorage.read(key: 'ACCESS_TOKEN');

    // If a token exists, add it to the request headers as a Bearer token.
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continue the request lifecycle by passing the (potentially modified)
    // options to the next handler in the chain.
    return handler.next(options);
  }
}
