import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/login_credentials_entity.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogInUseCase {
  final AuthRepository repository;

  LogInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required LogInCredentialsEntity credentials,
  }) {
    return repository.logIn(credentials: credentials);
  }
}
