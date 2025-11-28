// lib/features/auth/data/datasources/auth_remote_data_source_impl.dart
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/api/api_consumer.dart';
import 'package:tajalwaqaracademy/core/api/end_ponits.dart';
import 'package:tajalwaqaracademy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/auth_response_model.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/login_request_model.dart';
import 'package:tajalwaqaracademy/features/auth/data/models/user_model.dart';

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer _apiConsumer;

  AuthRemoteDataSourceImpl(this._apiConsumer);

  @override
  Future<AuthResponseModel> logIn(LoginRequestModel loginRequest) async {
    final response =
        await _apiConsumer.post(EndPoint.logIn, data: loginRequest.toJson());
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> forgetPassword(String email) async {
    await _apiConsumer.post(EndPoint.forgetPassword, data: {'email': email});
  }

  @override
  Future<UserModel> getUserProfile() async {
    final response = await _apiConsumer.get(EndPoint.user);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _apiConsumer.post(EndPoint.changePassword, data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  @override
  Future<AuthResponseModel> logInWithToken(String token) async {
    final response =
        await _apiConsumer.post(EndPoint.logInWithToken, data: {'token': token});
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
