// features/auth/data/datasources/auth_remote_data_source_impl.dart

import 'package:tajalwaqaracademy/core/errors/error_model.dart';

import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_ponits.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/sign_in_model.dart';
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
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final json = await api.post(
      EndPoint.login,
      data: {
        ApiKey.email: email,
        ApiKey.password: password,
      },
    );

    return _validateAndParse<UserModel>(
      json,
      (map) => UserModel.fromJson(map),
      
      'Invalid login response format',
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
      final error = ErrorModel.fromJson(json);
      throw ServerException(errorModel: error);
    }
    try {
      return parser(json as Map<String, dynamic>);
    } catch (_) {
      throw ServerException(
        errorModel: ErrorModel(status: 'error', message: parseErrorMessage),
      );
    }
  }
}
