// features/auth/domain/usecases/logOut_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/entities/success_entity.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class ForgetPasswordUseCase {
  final AuthRepository repository;
  ForgetPasswordUseCase(this.repository);

  Future<Either<Failure, SuccessEntity>> call({required String email}) {
    return repository.forgetPassword(email: email);
  }
}
