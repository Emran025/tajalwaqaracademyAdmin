// features/auth/data/datasources/auth_remote_data_source.dart

import '../models/sign_in_model.dart';

/// Defines remote data operations for authentication.
/// 
/// All methods throw [ServerException] carrying an [ErrorModel]
/// if the API responds with an error payload.
abstract class AuthRemoteDataSource {
  /// Sends credentials to the `/login` endpoint.
  Future<UserModel> login({
    required String email,
    required String password,
  });

}
