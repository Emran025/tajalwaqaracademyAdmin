import 'package:dartz/dartz.dart';

import '../entities/login_credentials_entity.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';


@injectable
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<String,UserEntity>> call({
    required
LoginCredentialsEntity credentials ,
  }) {
    return repository.login(
     credentials: credentials,
    );
  }
}



