
// features/auth/domain/usecases/logout_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/entities/success_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class ForgetPasswordUseCase {
  final AuthRepository repository;
  ForgetPasswordUseCase(this.repository);

    Future<Either<String,SuccessEntity>> call({
    required String email,
  }) {
    return repository.forgetPassword(
      email: email,
    );
  }
}



