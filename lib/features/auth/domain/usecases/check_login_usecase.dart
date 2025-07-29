
// features/auth/domain/usecases/check_login_usecase.dart
import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class CheckLoginUseCase {
  final AuthRepository repository;
  CheckLoginUseCase(this.repository);

  Future<bool> call() => repository.isLoggedIn();
}
