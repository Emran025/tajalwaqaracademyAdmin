import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// A Use Case responsible for retrieving the list of all users
/// currently stored in the local cache.
///
/// This is typically used to populate a "Switch Account" screen.
@lazySingleton
class GetAllUsersUseCase {
  final AuthRepository _authRepository;

  GetAllUsersUseCase(this._authRepository);

  /// Executes the use case.
  ///
  /// Returns:
  /// - [Right] with a `List<UserEntity>` if successful.
  /// - [Left] with a [Failure] if reading from the cache fails.
  Future<Either<Failure, List<UserEntity>>> call() async {
    return await _authRepository.getAllUsers();
  }
}
