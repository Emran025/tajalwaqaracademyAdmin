import 'dart:async';

import 'package:dio/dio.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tajalwaqaracademy/core/api/end_ponits.dart';

/// A Dio [QueuedInterceptorsWrapper] that handles automated token refreshing
/// logic for API requests.
///
/// This interceptor intercepts 401 Unauthorized responses, queues subsequent
/// requests, performs a token refresh using a stored refresh token, and then

/// retries the original failed request. This mechanism is critical for
/// providing a seamless user experience in token-based authentication systems.
final class TokenRefreshInterceptor extends QueuedInterceptorsWrapper {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  final Dio _tokenRefreshDio;

  /// A Completer used as a locking mechanism to prevent multiple, concurrent
  /// token refresh attempts, which could otherwise lead to race conditions
  /// and invalid tokens. When a refresh is in progress, this completer's
  /// future is awaited by subsequent failed requests.
  Completer<void>? _refreshCompleter;

  TokenRefreshInterceptor({
    required FlutterSecureStorage secureStorage,
    required Dio dio,
    required Dio tokenRefreshDio,
  }) : _secureStorage = secureStorage,
       _dio = dio,
       _tokenRefreshDio = tokenRefreshDio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // We only handle 401 Unauthorized errors.
    // We also check that the error is not from the refresh token endpoint itself
    // to prevent an infinite retry loop.
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(EndPoint.refreshToken)) {
      // If a refresh operation is already in progress, wait for it to complete.
      if (_refreshCompleter != null) {
        try {
          await _refreshCompleter!.future;
          // After waiting, retry the original request.
          await _retryRequest(err.requestOptions, handler);
        } on DioException catch (e) {
          // If the waiting request fails (because the refresh failed), pass the error.
          handler.next(e);
        }
        return;
      }

      // Lock the mechanism to prevent other 401s from triggering a new refresh.
      _refreshCompleter = Completer<void>();

      try {
        await _performTokenRefresh();
        // Mark the refresh as successfully completed.
        _refreshCompleter!.complete();
        // Retry the original request that initiated the refresh.
        await _retryRequest(err.requestOptions, handler);
      } on DioException catch (e) {
        // If the refresh fails, reject all queued requests with the new error.
        _refreshCompleter!.completeError(e);
        handler.next(e);
      } finally {
        // Reset the completer to allow for the next potential refresh cycle.
        _refreshCompleter = null;
      }
    } else {
      // For any other error, pass it down the interceptor chain.
      return handler.next(err);
    }
  }

  /// Executes the token refresh API call.
  /// Throws a [DioException] if the refresh fails, which is critical for the
  /// error handling logic in the `onError` method.
  Future<void> _performTokenRefresh() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) {
      // If there's no refresh token, the session is unrecoverable.
      // This will trigger a global logOut or re-authentication flow.
      await _secureStorage.deleteAll();
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'No refresh token available. User must re-authenticate.',
      );
    }

    try {
      final response = await _tokenRefreshDio.post(
        EndPoint.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data?['accessToken'] as String?;
      final newRefreshToken = response.data?['refreshToken'] as String?;

      if (newAccessToken == null) {
        // The server's response is invalid if the access token is missing.
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Refresh endpoint did not provide a new access token.',
        );
      }

      await _secureStorage.write(key: 'access_token', value: newAccessToken);
      if (newRefreshToken != null) {
        await _secureStorage.write(
          key: 'refresh_token',
          value: newRefreshToken,
        );
      }
    } on DioException {
      // If the refresh API call itself fails (e.g., 403 Forbidden),
      // it means the refresh token is also invalid. Clear session and rethrow.
      await _secureStorage.deleteAll();
      rethrow;
    }
  }

  /// Retries a request that previously failed.
  ///
  /// This method re-uses the original [RequestOptions] and lets Dio's
  /// interceptor chain (specifically the [AuthInterceptor]) handle the
  /// injection of the newly acquired token.
  Future<void> _retryRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      // `fetch` is used to re-execute the request with its original options.
      final response = await _dio.fetch(requestOptions);
      // If the retry is successful, resolve the handler to complete the cycle.
      handler.resolve(response);
    } on DioException catch (e) {
      // If the retried request also fails, pass the error on.
      handler.next(e);
    }
  }
}
