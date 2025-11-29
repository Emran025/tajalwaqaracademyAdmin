import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/entities/success_entity.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class LogOutUseCase {
  final AuthRepository repository;
  LogOutUseCase(this.repository);

  Future<Either<Failure, SuccessEntity>> call({
    required bool deleteCredentials,
  }) {
    return repository.logOut(deleteCredentials: deleteCredentials);
  }
}
