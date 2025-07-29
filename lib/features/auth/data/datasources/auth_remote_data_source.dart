// features/auth/data/datasources/auth_remote_data_source.dart

import '../../../../core/models/success_model.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';

/// Defines remote data operations for authentication.
///
/// All methods throw [ServerException] carrying an [ErrorModel]
/// if the API responds with an error payload.
abstract class AuthRemoteDataSource {
  /// Sends credentials to the `/login` endpoint.
  Future<AuthResponseModel> login({ required LoginRequestModel requestModel});

  /// Registers a new user via the `/signup` endpoint.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String phoneNumber,
    required String whatsappNumber,
    required String name,
    required String gender,
    required String birthDate,
    required String birthContery,
    required String birthStates,
    required String birthCity,
    required String profileImagePath,
    required String role,
    required String token,
    required String currentAddress,
  });


  /// Requests a password reset code.
  Future<SuccessModel> forgetPassword({required String email});

}
