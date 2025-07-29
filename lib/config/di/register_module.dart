import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:tajalwaqaracademy/core/api/api_consumer.dart';
import 'package:tajalwaqaracademy/core/api/dio_consumer.dart';
import 'package:tajalwaqaracademy/core/api/end_ponits.dart';
import 'package:tajalwaqaracademy/core/database/app_database.dart';
import 'package:tajalwaqaracademy/core/network/network_info.dart';
import 'package:workmanager/workmanager.dart'; // Import the contract, not the implementation

/// A unique identifier for the Dio instance dedicated to token refresh operations.
/// This named registration is crucial to prevent circular dependencies within interceptors.
const String dioForTokenRefresh = 'DioForTokenRefresh';

/// The Dependency Injection (DI) module for registering application-wide infrastructure services.
///
/// This class centralizes the setup of third-party libraries and core services,
/// such as the network client, database connections, and local storage. It ensures a
/// consistent and configurable dependency container for the entire application.
@module
abstract class RegisterModule {
  // =========================================================================
  //                             LOCAL STORAGE & DATABASE
  // =========================================================================

  /// Provides the singleton instance of the application's database helper.
  @lazySingleton
  AppDatabase get appDatabase => AppDatabase.instance;

  /// Provides the underlying [Database] object, ensuring it's initialized before use.
  @preResolve
  Future<Database> database(AppDatabase db) => db.database;

  /// Provides the singleton instance of [SharedPreferences] for simple key-value storage.
  /// The [preResolve] annotation ensures that the instance is ready before the app starts.
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// Provides the singleton instance of [FlutterSecureStorage] for secure data persistence.
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  // =========================================================================
  //                             NETWORK STACK
  // =========================================================================

  /// Provides a dedicated, minimalist Dio instance for the token refresh mechanism.
  ///
  /// This instance is intentionally stripped of interceptors to avoid recursive
  /// error handling cycles. It is uniquely identified by the [dioForTokenRefresh] name.
  @Named(dioForTokenRefresh)
  @lazySingleton
  Dio dioForTokenRefreshInstance() => Dio(
    BaseOptions(
      baseUrl: EndPoint.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  /// Provides the main, fully-configured Dio instance for all standard API requests.
  ///
  /// This instance is equipped with a critical chain of interceptors whose order
  /// is crucial for correct behavior. This setup is centralized here to ensure
  /// consistency and ease of maintenance.
  @lazySingleton
  Dio dio(
    FlutterSecureStorage storage,
    @Named(dioForTokenRefresh) Dio tokenRefreshDio,
  ) {
    final mainDio = Dio(
      BaseOptions(
        baseUrl: EndPoint.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // The interceptor chain. Order matters:
    // 1. AuthInterceptor: Injects the token.
    // 2. TokenRefreshInterceptor: Handles 401s if the token is expired.
    // 3. LogInterceptor: Logs the final state of the request.
    mainDio.interceptors.addAll([
      // TEMP: The authentication interceptors are temporarily disabled.
      // To enable token-based authentication, uncomment the following lines.
      // -------------------------------------------------------------------
      // AuthInterceptor(secureStorage: storage),
      // TokenRefreshInterceptor(
      //   secureStorage: storage,
      //   dio: mainDio,
      //   tokenRefreshDio: tokenRefreshDio,
      // ),
      // -------------------------------------------------------------------

      // LogInterceptor is essential for debugging network issues.
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);
    return mainDio;
  }

  /// Provides the concrete implementation of the [ApiConsumer] interface.
  ///
  /// This registration depends on the main [Dio] instance and will automatically
  /// receive the fully configured version from the DI container.
  @lazySingleton
  ApiConsumer apiConsumer(Dio dio) => DioConsumer(dio: dio);

  // =========================================================================
  //                             UTILITY SERVICES
  // =========================================================================

  /// Provides the singleton instance of the third-party internet connection checker.
  /// This is a concrete dependency required by our [NetworkInfoImpl].
  @lazySingleton
  InternetConnection get connectionChecker => InternetConnection();

  /// Provides the singleton instance of the third-party device info plugin.
  /// This is a concrete dependency required by our [DeviceInfoServiceImpl].
  @lazySingleton
  DeviceInfoPlugin get deviceInfoPlugin => DeviceInfoPlugin();

  /// Provides the singleton instance of the WorkManager plugin.
  /// This is the core engine for scheduling and running background tasks.
  @lazySingleton
  Workmanager get workmanager => Workmanager();

  // NOTE: NetworkInfoImpl and PushNotificationService implementations
  // are registered automatically by @injectable because their implementation
  // classes (`NetworkInfoImpl` and `DummyPushNotificationServiceImpl`)
  // are annotated with `@LazySingleton(as: ...)`
}
