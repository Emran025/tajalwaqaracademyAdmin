import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/errors/exceptions.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

/// Orchestrates calls to [AuthRemoteDataSource], catches any
/// [ServerException], and exposes a clean [Either]<String, T> API.
/// Coordinates remote + local sources, and exposes
/// a clean Either<String,T> API for network calls,
/// plus async getters for cached data.



@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;
  AuthRepositoryImpl(this.remote, this.local);

  /// Utility to wrap a remote call and map a [ServerException]
  /// to a `Left<String>`.
  Future<Either<String, T>> _wrap<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Right(result);
    } on ServerException catch (e) {
      return Left(e.errorModel.message);
    }
  }

@override
Future<Either<String, UserEntity>> login({
  required String email,
  required String password,
}) async {
  // 1) استدعاء API ويُعيد Either<String, SignInModel>
  final either = await _wrap(
    () => remote.login(email: email, password: password),
  );

  // 2) تحويل SignInModel إلى UserEntity داخل Right فقط
  return either.map((userModel) {
    final userEntity = userModel.toUserEntity();
    local.cacheUser(userModel);
    return userEntity;
  });
}



}
