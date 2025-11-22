// features/auth/data/datasources/auth_remote_data_source.dart

import '../../../../core/models/success_model.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';

/// Defines remote data operations for authentication.
///
/// All methods throw [ServerException] carrying an [ErrorModel]
/// if the API responds with an error payload.
abstract class AuthRemoteDataSource {
  /// Sends credentials to the `/logIn` endpoint.
  Future<AuthResponseModel> logIn({required LogInRequestModel requestModel});

  /// Requests a password reset code.
  Future<SuccessModel> forgetPassword({required String email});
  Future<SuccessModel> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Requests a password reset code.
  Future<SuccessModel> logOut();
}
