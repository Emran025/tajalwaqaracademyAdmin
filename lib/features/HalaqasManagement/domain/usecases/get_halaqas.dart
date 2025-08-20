import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/halaqa_list_item_entity.dart';
import '../repositories/halaqa_repository.dart';
import 'usecase.dart';

/// A use case that provides a real-time stream of the halaqa list.
///
/// This use case subscribes to the [HalaqaRepository] to get a stream of
/// halaqas. It follows the "Stale-While-Revalidate" pattern implicitly, as the
/// repository handles the background synchronization.
@lazySingleton
class WatchHalaqasUseCase
    extends StreamUseCase<List<HalaqaListItemEntity>, WatchHalaqasParams> {
  final HalaqaRepository _repository;

  WatchHalaqasUseCase({required HalaqaRepository repository})
    : _repository = repository;

  /// Calls the repository to get a stream of halaqas.
  ///
  /// The stream will immediately emit the cached data and then emit new data
  /// whenever the local database is updated by the background sync process.
  @override
  Stream<Either<Failure, List<HalaqaListItemEntity>>> call(
    WatchHalaqasParams params,
  ) {
    // The use case acts as a clean proxy to the repository method.
    return _repository.getHalaqas(forceRefresh: params.forceRefresh);
  }
}

/// Parameters for the [WatchHalaqasUseCase].

@injectable
class WatchHalaqasParams extends Equatable {
  /// When `true`, it signals to the repository to force a background sync.
  /// This is useful for user-initiated "pull-to-refresh" actions.
  final bool forceRefresh;

  const WatchHalaqasParams({this.forceRefresh = true});

  @override
  List<Object?> get props => [forceRefresh];
}
