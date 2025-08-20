// path: lib/features/settings/domain/usecases/save_theme.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/themes/app_theme.dart'; // Assuming AppThemeType enum path
import '../repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Persists the user's selected application theme.
///
/// This use case is responsible for the single, atomic action of saving the
/// chosen theme. It returns [void] on success, as the operation does not
/// yield any data, only a confirmation of completion.
@lazySingleton
class SaveTheme implements UseCase<void, SaveThemeParams> {
  final SettingsRepository _repository;

  SaveTheme(this._repository);

  /// Executes the use case to save the theme.
  @override
  Future<Either<Failure, void>> call(SaveThemeParams params) async {
    return await _repository.saveTheme(params.themeType);
  }
}

/// Encapsulates the parameters required for the [SaveTheme] use case.
///
/// Using a dedicated parameters class enhances scalability and readability,
/// allowing future parameters to be added without altering the use case signature.
class SaveThemeParams extends Equatable {
  final AppThemeType themeType;

  const SaveThemeParams({required this.themeType});

  @override
  List<Object> get props => [themeType];
}