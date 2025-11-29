import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// A Use Case responsible for changing the currently active user session.
/// 
/// It takes a [userId], updates the local session pointer, and returns
/// the profile of the new user.
@lazySingleton
class SwitchUserUseCase {
  final AuthRepository _authRepository;

  SwitchUserUseCase(this._authRepository);

  Future<Either<Failure, UserEntity>> call({required String userId}) async {
    return await _authRepository.switchUser(userId: userId);
  }
}