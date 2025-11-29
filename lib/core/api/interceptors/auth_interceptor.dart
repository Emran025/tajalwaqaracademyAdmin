import 'dart:convert'; // Required for json.decode
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tajalwaqaracademy/core/api/end_ponits.dart';

// Define the key locally or import it from your constants file
const String _kAccessTokensListKey = 'ACCESS_TOKENS_LIST';

/// A Dio interceptor responsible for automatically injecting the
/// `Authorization` header with a Bearer token into outgoing API requests.
///
/// This interceptor has been updated to support Multi-User sessions.
/// It fetches the list of tokens from secure storage and uses the first one
/// (Index 0), which corresponds to the currently active user.
final class AuthInterceptor extends Interceptor {
  /// The secure storage mechanism used to persist and retrieve authentication tokens.
  final FlutterSecureStorage _secureStorage;

  /// Constructs an [AuthInterceptor].
  AuthInterceptor({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Skip token injection for endpoints that don't need auth or handle it differently.
    if (options.path.contains(EndPoint.refreshToken) ||
        options.path.contains(EndPoint.logIn) ||
        options.path.contains(EndPoint.forgetPassword)) {
      return handler.next(options);
    }

    try {
      // 2. Read the JSON string list using the new key.
      final String? jsonString = await _secureStorage.read(
        key: _kAccessTokensListKey,
      );

      if (jsonString != null) {
        // 3. Decode the JSON string into a List.
        final List<dynamic> tokensList = json.decode(jsonString);

        // 4. Check if the list is valid and not empty.
        // We always take the FIRST element (Index 0) as it represents the CURRENT USER.
        if (tokensList.isNotEmpty) {
          final currentTokenMap = tokensList.first;

          // 5. Extract the 'token' field.
          final String? token = currentTokenMap['token'];

          // 6. Inject the token into the header.
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
      }
    } catch (e) {
      // Fails silently if JSON is corrupted or storage fails,
      // allowing the request to proceed (it will likely return 401).
    }

    // Continue the request lifecycle.
    return handler.next(options);
  }
}
