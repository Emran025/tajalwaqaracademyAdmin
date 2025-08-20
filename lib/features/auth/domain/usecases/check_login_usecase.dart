// features/auth/domain/usecases/check_logIn_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CheckLogInUseCase {
  final AuthRepository repository;
  CheckLogInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() => repository.getUserProfile();
}
