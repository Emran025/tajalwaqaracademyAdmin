// path: lib/features/settings/domain/entities/user_profile_entity.dart

import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart'; // Assuming path to your existing UserEntity from Auth
import 'user_session_entity.dart';

/// Represents the complete, consolidated data model for the User Profile screen.
///
/// This entity is a cornerstone of the "Settings" feature, acting as a composite
/// object that aggregates the user's static identity with their dynamic session
/// information. This design decouples the profile screen from the underlying
/// data sources and provides a single, immutable source of truth for the UI.
///
/// It facilitates all required functionalities:
/// - **Display:** The nested `user` object provides all necessary personal data.
/// - **Editing:** The UI can use the `user` object's data to pre-fill editing forms.
/// - **Session Management:** The `activeSessions` list provides the data to render
///   session cards and the necessary `id` within each [UserSessionEntity] to
///   perform a "remove session" action.
class UserProfileEntity extends Equatable {
  /// The core, static identity of the user, reused from the authentication domain.
  /// This promotes the DRY (Don't Repeat Yourself) principle.
  final UserEntity user;

  /// A list of all currently active login sessions for this user account.
  /// The list is ordered, typically with the most recent session first.
  final List<UserSessionEntity> activeSessions;

  const UserProfileEntity({
    required this.user,
    required this.activeSessions,
  });

  @override
  List<Object> get props => [user, activeSessions];
}