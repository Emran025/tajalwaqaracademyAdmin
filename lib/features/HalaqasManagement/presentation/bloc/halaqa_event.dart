part of 'halaqa_bloc.dart';

sealed class HalaqaEvent extends Equatable {
  const HalaqaEvent();
  @override
  List<Object> get props => [];
}

/// Dispatched to initialize the BLoC and start watching the halaqa list.
/// Should be called once when the feature is first accessed.
final class WatchHalaqasStarted extends HalaqaEvent {
  const WatchHalaqasStarted();
}

/// Dispatched by the user via a pull-to-refresh gesture to force a sync.
final class HalaqasRefreshed extends HalaqaEvent {
  const HalaqasRefreshed();
}

/// Dispatched when the user scrolls to the end of the list to load more data.
final class MoreHalaqasLoaded extends HalaqaEvent {
  const MoreHalaqasLoaded();
}

/// Dispatched when the user performs an action to add or update a halaqa.
final class HalaqaUpserted extends HalaqaEvent {
  final HalaqaDetailEntity halaqa;
  const HalaqaUpserted(this.halaqa);
  @override
  List<Object> get props => [halaqa];
}

/// Internal event used to push updates from the data stream into the BLoC.
final class _HalaqasStreamUpdated extends HalaqaEvent {
  final Either<Failure, List<HalaqaListItemEntity>> update;
  const _HalaqasStreamUpdated(this.update);
  @override
  List<Object> get props => [update];
}

final class FilteredHalaqas extends HalaqaEvent {
   final ActiveStatus? status;
 final DateTime? trackDate;
 final Frequency? frequencyCode;

  const FilteredHalaqas({
    this.status,
    this.trackDate,
    this.frequencyCode,
  });
}

/// Dispatched when the user navigates to a halaqa's profile screen
/// to fetch their detailed information.
final class HalaqaDetailsFetched extends HalaqaEvent {
  final String halaqaId;
  const HalaqaDetailsFetched(this.halaqaId);

  @override
  List<Object> get props => [halaqaId];
}

/// Dispatched when the user confirms the deletion of a halaqa.
final class HalaqaDeleted extends HalaqaEvent {
  final String halaqaId;
  const HalaqaDeleted(this.halaqaId);
  @override
  List<Object> get props => [halaqaId];
}

// --- Custom Status Change Events ---

/// Dispatched to change a halaqa's status (e.g., accept or suspend).
final class HalaqaStatusChanged extends HalaqaEvent {
  final String halaqaId;
  final ActiveStatus newStatus;
  const HalaqaStatusChanged(this.halaqaId, this.newStatus);
  @override
  List<Object> get props => [halaqaId, newStatus];
}
