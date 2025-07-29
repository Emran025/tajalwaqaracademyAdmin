import 'package:injectable/injectable.dart';

import 'push_notification_service.dart';

/// A placeholder implementation of [PushNotificationService] for development
/// and testing environments where a real push notification provider is not configured.
///
/// This class returns a hardcoded, non-functional token. It allows the
/// application to run without crashing and ensures that the dependency on
/// [PushNotificationService] is always met.
@LazySingleton(as: PushNotificationService)
final class DummyPushNotificationServiceImpl implements PushNotificationService {
  
  /// Returns a constant placeholder token.
  @override
  Future<String> getPushToken() async {
    // This simulates a small delay, similar to a real network call.
    await Future.delayed(const Duration(milliseconds: 50));
    print('[PushNotificationService] NOTICE: Using a dummy push token for development.');
    return 'dummy_push_token_for_development_env';
  }
}