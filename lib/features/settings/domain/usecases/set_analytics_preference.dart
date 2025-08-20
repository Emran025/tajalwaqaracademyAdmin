// path: lib/features/settings/domain/usecases/set_analytics_preference.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Updates the user's preference for analytics data collection.
@lazySingleton
class SetAnalyticsPreference implements UseCase<void, SetAnalyticsPreferenceParams> {
  final SettingsRepository _repository;

  SetAnalyticsPreference(this._repository);

  /// Executes the use case to persist the analytics preference.
  @override
  Future<Either<Failure, void>> call(SetAnalyticsPreferenceParams params) async {
    return await _repository.setAnalyticsPreference(params.isEnabled);
  }
}

/// Encapsulates the parameters for the [SetAnalyticsPreference] use case.
class SetAnalyticsPreferenceParams extends Equatable {
  final bool isEnabled;

  const SetAnalyticsPreferenceParams({required this.isEnabled});

  @override
  List<Object> get props => [isEnabled];
}