// lib/features/auth/domain/usecases/get_device_accounts_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/auth/domain/entities/device_account_entity.dart';
import 'package:tajalwaqaracademy/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class GetDeviceAccountsUseCase
    implements UseCase<List<DeviceAccountEntity>, NoParams> {
  final AuthRepository _repository;

  GetDeviceAccountsUseCase(this._repository);

  @override
  Future<Either<Failure, List<DeviceAccountEntity>>> call(
      NoParams params) async {
    return await _repository.getDeviceAccounts();
  }
}
