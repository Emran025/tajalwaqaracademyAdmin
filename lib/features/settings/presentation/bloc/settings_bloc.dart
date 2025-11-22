import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; // You might need this
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:tajalwaqaracademy/features/settings/domain/usecases/get_latest_policy_usecase.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/settings_entity.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/user_profile_entity.dart';
import 'package:tajalwaqaracademy/features/settings/domain/usecases/get_settings.dart';
import 'package:tajalwaqaracademy/features/settings/domain/usecases/get_user_profile.dart';
import 'package:tajalwaqaracademy/features/settings/domain/usecases/save_theme.dart';
import 'package:tajalwaqaracademy/features/settings/domain/usecases/set_analytics_preference.dart';
import 'package:tajalwaqaracademy/features/settings/domain/usecases/set_notifications_preference.dart';
import 'package:tajalwaqaracademy/features/settings/domain/usecases/update_user_profile.dart';

import '../../domain/entities/privacy_policy_entity.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// Manages the state and business logic for the entire settings feature.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings _getSettings;
  final SaveTheme _saveTheme;
  final SetNotificationsPreference _setNotificationsPreference;
  final SetAnalyticsPreference _setAnalyticsPreference;
  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final GetLatestPolicyUseCase _getLatestPolicy;

  SettingsBloc({
    required GetSettings getSettings,
    required SaveTheme saveTheme,
    required SetNotificationsPreference setNotificationsPreference,
    required SetAnalyticsPreference setAnalyticsPreference,
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
    required GetLatestPolicyUseCase getLatestPolicy,
  }) : _getSettings = getSettings,
       _saveTheme = saveTheme,
       _setNotificationsPreference = setNotificationsPreference,
       _setAnalyticsPreference = setAnalyticsPreference,
       _getUserProfile = getUserProfile,
       _updateUserProfile = updateUserProfile,
       _getLatestPolicy = getLatestPolicy,
       super(SettingsInitial()) {
    // Register event handlers
    on<LoadInitialSettings>(_onLoadInitialSettings);
    on<LoadUserProfile>(_onLoadUserProfile, transformer: droppable());
    on<LoadPrivacyPolicy>(_onLoadPrivacyPolicy, transformer: droppable());
    on<ThemeChanged>(_onThemeChanged, transformer: restartable());
    on<NotificationsPreferenceChanged>(
      _onNotificationsPreferenceChanged,
      transformer: restartable(),
    );
    on<AnalyticsPreferenceChanged>(
      _onAnalyticsPreferenceChanged,
      transformer: restartable(),
    );
    on<UpdateProfileRequested>(
      _onUpdateProfileRequested,
      transformer: droppable(),
    );
  }

  /// A common handler for all preference change events.
  ///
  /// This robust pattern ensures state consistency by:
  /// 1. Performing the save operation.
  /// 2. Immediately re-fetching all settings from the single source of truth (storage).
  /// 3. Emitting a new state based on the freshly fetched data.
  /// This eliminates optimistic UI bugs and issues related to Hot Reload.
  Future<void> _handlePreferenceChange(
    Future<void> Function() saveOperation,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoadSuccess) return;

    // 1. Perform the save operation.
    await saveOperation();

    // 2. Re-fetch all settings from the repository (the single source of truth).
    final result = await _getSettings(NoParams());

    // 3. Emit the new state based on the fetched data.
    result.fold(
      (failure) =>
          emit(SettingsLoadFailure(failure)), // Or handle error differently
      (newSettings) {
        // We must use the old state's other properties (like userProfile)
        // and combine them with the new settings.
        final currentState = state as SettingsLoadSuccess;
        emit(currentState.copyWith(settings: newSettings));
      },
    );
  }

  Future<void> _onLoadInitialSettings(
    LoadInitialSettings event,
    Emitter<SettingsState> emit,
  ) async {
    // This remains the same.
    final result = await _getSettings(NoParams());
    result.fold(
      (failure) => emit(SettingsLoadFailure(failure)),
      (settings) => emit(SettingsLoadSuccess(settings: settings)),
    );
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _handlePreferenceChange(
      () => _saveTheme(SaveThemeParams(themeType: event.newTheme)),
      emit,
    );
  }

  Future<void> _onNotificationsPreferenceChanged(
    NotificationsPreferenceChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _handlePreferenceChange(
      () => _setNotificationsPreference(
        SetNotificationsPreferenceParams(isEnabled: event.isEnabled),
      ),
      emit,
    );
  }

  Future<void> _onAnalyticsPreferenceChanged(
    AnalyticsPreferenceChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _handlePreferenceChange(
      () => _setAnalyticsPreference(
        SetAnalyticsPreferenceParams(isEnabled: event.isEnabled),
      ),
      emit,
    );
  }

  // The rest of the handlers (_onLoadUserProfile, etc.) remain the same
  // as they fetch data and don't modify the core settings object.
  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoadSuccess) return;

    final currentState = state as SettingsLoadSuccess;
    emit(currentState.copyWith(profileStatus: SectionStatus.loading));
    final result = await _getUserProfile(NoParams());

    result.fold(
      (failure) => emit(
        currentState.copyWith(
          profileStatus: SectionStatus.failure,
          error: failure,
        ),
      ),
      (profile) => emit(
        currentState.copyWith(
          profileStatus: SectionStatus.success,
          userProfile: profile,
        ),
      ),
    );
  }

  Future<void> _onLoadPrivacyPolicy(
    LoadPrivacyPolicy event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoadSuccess) return;
    final currentState = state as SettingsLoadSuccess;
    emit(currentState.copyWith(policyStatus: SectionStatus.loading));
    final result = await _getLatestPolicy(NoParams());
    result.fold(
      (failure) => emit(
        currentState.copyWith(
          policyStatus: SectionStatus.failure,
          error: failure,
        ),
      ),
      (policy) => emit(
        currentState.copyWith(
          policyStatus: SectionStatus.success,
          privacyPolicy: policy,
        ),
      ),
    );
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoadSuccess) return;
    final currentState = state as SettingsLoadSuccess;
    emit(
      currentState.copyWith(
        actionStatus: ActionStatus.loading,
        clearError: true,
      ),
    );
    final result = await _updateUserProfile(
      UpdateUserProfileParams(userProfile: event.userProfile),
    );
    result.fold(
      (failure) => emit(
        currentState.copyWith(
          actionStatus: ActionStatus.failure,
          error: failure,
        ),
      ),
      (_) => emit(
        currentState.copyWith(
          actionStatus: ActionStatus.success,
          userProfile: event.userProfile,
        ),
      ),
    );
  }
}
