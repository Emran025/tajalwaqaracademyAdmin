import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tajalwaqaracademy/core/network/network_info.dart';

/// The concrete implementation of the [NetworkInfo] contract.
///
/// This class utilizes the `internet_connection_checker_plus` package to
/// determine the device's network connectivity status. It is registered with
/// the dependency injection container to be provided wherever a [NetworkInfo]
/// instance is required.
@LazySingleton(as: NetworkInfo)
final class NetworkInfoImpl implements NetworkInfo {
  /// The instance of the connection checker from the third-party package.
  /// This is kept private to encapsulate the implementation detail.
  final InternetConnection _connectionChecker;

  /// Constructs a [NetworkInfoImpl].
  ///
  /// It requires an [InternetConnection] instance, which is supplied by the
  /// dependency injection container, promoting loose coupling.
  NetworkInfoImpl({required InternetConnection connectionChecker})
      : _connectionChecker = connectionChecker;

  /// Checks the network status by calling the underlying library's method.
  @override
  Future<bool> get isConnected => _connectionChecker.hasInternetAccess;
}