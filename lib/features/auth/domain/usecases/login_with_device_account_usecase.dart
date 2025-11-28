// lib/features/auth/domain/usecases/login_with_device_account_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/user_entity.dart';
import 'package:tajalwaqaracademy/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class LogInWithDeviceAccountUseCase
    implements UseCase<UserEntity, LogInWithDeviceAccountParams> {
  final AuthRepository _repository;

  LogInWithDeviceAccountUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(
      LogInWithDeviceAccountParams params) async {
    return await _repository.logInWithDeviceAccount(params.userId);
  }
}

class LogInWithDeviceAccountParams extends Equatable {
  final int userId;

  const LogInWithDeviceAccountParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
