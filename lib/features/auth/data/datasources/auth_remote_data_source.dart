// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'package.tajalwaqaracademy/features/auth/data/models/auth_response_model.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/login_request_model.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> logIn(LoginRequestModel loginRequest);
  Future<void> forgetPassword(String email);
  Future<UserModel> getUserProfile();
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<AuthResponseModel> logInWithToken(String token);
}
