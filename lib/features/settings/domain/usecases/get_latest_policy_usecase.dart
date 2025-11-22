import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/settings/domain/repositories/settings_repository.dart';

import '../entities/privacy_policy_entity.dart';

/// A domain-layer use case responsible for retrieving the latest privacy policy.
///
/// This class encapsulates the specific business rule of fetching the privacy
/// policy. It acts as a clean, testable bridge between the presentation layer
//  (e.g., a BLoC or ViewModel) and the data orchestration logic in the
/// [SettingsRepository]. Its single responsibility makes the system's
/// architecture more modular and easier to understand.
@lazySingleton
class GetLatestPolicyUseCase implements UseCase<PrivacyPolicyEntity, NoParams> {
  /// The repository that will be used to fetch the data.
  ///
  /// By depending on the abstract [SettingsRepository], this use case remains
  /// decoupled from the data layer's implementation details.
  final SettingsRepository _repository;

  /// Creates an instance of [GetLatestPolicyUseCase].
  ///
  /// The [SettingsRepository] dependency will be provided by the dependency
  /// injection framework.
  GetLatestPolicyUseCase(this._repository);

  /// Executes the use case.
  ///
  /// This method orchestrates the call to the repository to get the privacy
  /// policy. It adheres to the [UseCase] contract, taking [NoParams] as input
  /// since this operation does not require any parameters.
  ///
  /// Returns a [Future] containing either a [Failure] on error or the
  /// [PrivacyPolicyEntity] on success.
  @override
  Future<Either<Failure, PrivacyPolicyEntity>> call(NoParams params) async {
    // Delegate the call directly to the repository. The repository handles
    // the complex logic of remote vs. local fetching, and this use case
    // simply exposes that functionality to the presentation layer.
    return await _repository.getLatestPolicy();
  }
}
