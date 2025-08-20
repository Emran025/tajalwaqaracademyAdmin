// path: lib/features/settings/domain/entities/user_session_entity.dart

import 'package:equatable/equatable.dart';


import '../../../auth/domain/entities/device_info_entity.dart'; // Assuming path to your existing DeviceInfoEntity

/// Represents a single, unique user session on a specific device.
///
/// This domain entity is a critical component of the user profile, providing
/// the necessary data to display a list of active sessions. It's designed
/// to be immutable and provides value equality.
class UserSessionEntity extends Equatable {
  /// A unique identifier for the session, essential for targeted actions
  /// like remote sign-out.
  final String id;

  /// A flag indicating if this session corresponds to the device currently
  /// being used. This is a critical UX element to prevent a user from
  /// accidentally logging themselves out.
  final bool isCurrentDevice;

  /// The timestamp of the last authenticated activity for this session.
  /// Used to help the user identify old or suspicious sessions.
  final DateTime lastAccessedAt;

  /// The detailed hardware and software snapshot of the device associated
  /// with this session.
  final DeviceInfoEntity deviceInfo;

  const UserSessionEntity({
    required this.id,
    required this.isCurrentDevice,
    required this.lastAccessedAt,
    required this.deviceInfo,
  });

  @override
  List<Object> get props => [id, isCurrentDevice, lastAccessedAt, deviceInfo];
}