// path: lib/features/settings/domain/usecases/get_user_profile.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Fetches the profile data for the currently authenticated user.
///
/// This use case is distinct from `GetSettings` as it deals with user-specific,
/// often mutable data (name, email, avatar URL) which is typically sourced
/// from a remote backend.
@lazySingleton
class GetUserProfile implements UseCase<UserProfileEntity, NoParams> {
  final SettingsRepository _repository;

  GetUserProfile(this._repository);

  /// Executes the use case to retrieve the user profile.
  @override
  Future<Either<Failure, UserProfileEntity>> call(NoParams params) async {
    return await _repository.getUserProfile();
  }
}