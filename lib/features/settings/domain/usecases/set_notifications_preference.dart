// path: lib/features/settings/domain/usecases/set_notifications_preference.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Updates the user's preference for receiving push notifications.
@lazySingleton
class SetNotificationsPreference implements UseCase<void, SetNotificationsPreferenceParams> {
  final SettingsRepository _repository;

  SetNotificationsPreference(this._repository);

  /// Executes the use case to persist the notification preference.
  @override
  Future<Either<Failure, void>> call(SetNotificationsPreferenceParams params) async {
    return await _repository.setNotificationsPreference(params.isEnabled);
  }
}

/// Encapsulates the parameters for the [SetNotificationsPreference] use case.
class SetNotificationsPreferenceParams extends Equatable {
  final bool isEnabled;

  const SetNotificationsPreferenceParams({required this.isEnabled});

  @override
  List<Object> get props => [isEnabled];
}