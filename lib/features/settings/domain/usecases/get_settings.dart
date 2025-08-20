// path: lib/features/settings/domain/usecases/get_settings.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Fetches the consolidated settings configuration for the application.
///
/// This use case orchestrates the retrieval of all user-defined preferences
/// (such as theme, notifications, etc.) from the repository, returning them
/// as a single, immutable [SettingsEntity]. It acts as the single source
/// of truth for the presentation layer when initializing the settings view.
@lazySingleton
class GetSettings implements UseCase<SettingsEntity, NoParams> {
  final SettingsRepository _repository;

  /// Depends on the [SettingsRepository] abstraction to adhere to the
  /// Dependency Inversion Principle.
  GetSettings(this._repository);

  /// Executes the use case.
  ///
  /// Returns a [Failure] on error or a [SettingsEntity] on success.
  @override
  Future<Either<Failure, SettingsEntity>> call(NoParams params) async {
    return await _repository.getSettings();
  }
}