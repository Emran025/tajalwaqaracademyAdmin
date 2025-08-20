// path: lib/features/settings/domain/usecases/update_user_profile.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Submits updated user profile data to the backend.
///
/// This use case handles the complex operation of updating user data,
/// which may involve API calls and data validation. It takes a complete
/// entity object to ensure data consistency.
@lazySingleton
class UpdateUserProfile implements UseCase<void, UpdateUserProfileParams> {
  final SettingsRepository _repository;

  UpdateUserProfile(this._repository);

  /// Executes the use case to persist the profile changes.
  @override
  Future<Either<Failure, void>> call(UpdateUserProfileParams params) async {
    // Here you could add domain-level validation if needed before calling the repository.
    // For example: if (!params.userProfile.email.isValid) return Left(ValidationFailure());
    return await _repository.updateUserProfile(params.userProfile);
  }
}

/// Encapsulates the parameters for the [UpdateUserProfile] use case.
class UpdateUserProfileParams extends Equatable {
  final UserProfileEntity userProfile;

  const UpdateUserProfileParams({required this.userProfile});

  @override
  List<Object> get props => [userProfile];
}