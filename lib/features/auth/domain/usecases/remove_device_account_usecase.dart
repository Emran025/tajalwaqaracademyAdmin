// lib/features/auth/domain/usecases/remove_device_account_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/entities/success_entity.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class RemoveDeviceAccountUseCase
    implements UseCase<SuccessEntity, RemoveDeviceAccountParams> {
  final AuthRepository _repository;

  RemoveDeviceAccountUseCase(this._repository);

  @override
  Future<Either<Failure, SuccessEntity>> call(
      RemoveDeviceAccountParams params) async {
    return await _repository.removeDeviceAccount(params.userId);
  }
}

class RemoveDeviceAccountParams extends Equatable {
  final int userId;

  const RemoveDeviceAccountParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
