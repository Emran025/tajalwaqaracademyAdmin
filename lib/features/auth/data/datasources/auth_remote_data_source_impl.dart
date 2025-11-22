// features/auth/data/datasources/auth_remote_data_source_impl.dart

import 'package:tajalwaqaracademy/core/error/failures.dart';

import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_ponits.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/success_model.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import 'auth_remote_data_source.dart';
import 'package:injectable/injectable.dart';

/// Implementation of [AuthRemoteDataSource] that calls the real HTTP API.
///
/// - On success: parses JSON into the appropriate Model.
/// - On error: throws [ServerException] carrying the server-returned [ErrorModel].
///

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer api;

  AuthRemoteDataSourceImpl(this.api);
  @override
  Future<AuthResponseModel> logIn({
    required LogInRequestModel requestModel,
  }) async {
    // The ApiConsumer is pre-configured to handle all non-2xx status codes
    // and network errors by throwing a ServerException.
    final responseJson = await api.post(
      EndPoint.logIn, // e.g., '/v1/auth/logIn'
      data: requestModel.toJson(),
    );

    // If the code reaches this point, the request was successful (status 2xx).
    // The only remaining task is to parse the successful response body.
    return AuthResponseModel.fromJson(responseJson as Map<String, dynamic>);
  }

  @override
  Future<SuccessModel> forgetPassword({required String email}) async {
    final json = await api.post(
      EndPoint.forgetPassword,
      data: {ApiKey.email: email},
    );

    return _validateAndParse<SuccessModel>(
      json,
      (map) => SuccessModel.fromJson(map),
      'Invalid forget-pass response format',
    );
  }

  @override
  Future<SuccessModel> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final json = await api.post(
      EndPoint.changePassword, // ستحتاج لتعريف هذا ال endpoint
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );

    return _validateAndParse<SuccessModel>(
      json,
      (map) => SuccessModel.fromJson(map),
      'Invalid change-password response format',
    );
  }

  @override
  Future<SuccessModel> logOut() async {
    final json = await api.post(EndPoint.logOut);
    return _validateAndParse<SuccessModel>(
      json,
      (map) => SuccessModel.fromJson(map),
      'Invalid forget-pass response format',
    );
  }

  /// Helper that checks for server-error payload and parses the JSON.
  ///
  /// If the server always returns:
  ///   • `{ status: "error", message: "..." }` on failure, or
  ///   • a valid object on success,
  /// then this method:
  ///   1) throws [ServerException] with [ErrorModel.fromJson] when `status == "error"`,
  ///   2) otherwise applies [parser] to the JSON map,
  ///   3) or throws [ServerException] on any parsing failure.
  T _validateAndParse<T>(
    dynamic json,
    T Function(Map<String, dynamic>) parser,
    String parseErrorMessage,
  ) {
    if (json is Map<String, dynamic> && json[ApiKey.status] == 'error') {
      // API-side error
      // API-side error
      final error = ErrorModel.fromJson(json);
      throw ServerException(statusCode: error.status, message: error.message);
    }
    try {
      return parser(json as Map<String, dynamic>);
    } catch (_) {
      throw ServerException(statusCode: 'error', message: parseErrorMessage);
    }
  }
}
