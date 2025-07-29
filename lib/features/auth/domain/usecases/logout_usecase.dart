
// features/auth/domain/usecases/logout_usecase.dart
import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<void> call() => repository.logout();
}



