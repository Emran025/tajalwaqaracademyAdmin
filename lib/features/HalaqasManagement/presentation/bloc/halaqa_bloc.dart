import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
// import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/active_status.dart';
import '../../domain/entities/halaqa_entity.dart';
import '../../domain/entities/halaqa_list_item_entity.dart';
import '../../domain/usecases/halaqa_halaqa_usecase.dart';
import '../../domain/usecases/fetch_more_halaqas_usecase.dart';
import '../../domain/usecases/get_halaqa_by_id.dart';
import '../../domain/usecases/get_halaqas.dart';
import '../../domain/usecases/set_halaqa_status_params.dart';
import '../../domain/usecases/upsert_halaqa_usecase.dart';

part 'halaqa_event.dart';
part 'halaqa_state.dart';

// @injectable
class HalaqaBloc extends Bloc<HalaqaEvent, HalaqaState> {
  final WatchHalaqasUseCase _watchHalaqas;
  final FetchMoreHalaqasUseCase _fetchMoreHalaqas;
  final GetHalaqaById _getHalaqaById;
  final UpsertHalaqa _upsertHalaqa;
  final DeleteHalaqaUseCase _deleteHalaqa;
  final SetHalaqaStatusUseCase _setHalaqaStatus;

  StreamSubscription<Either<Failure, List<HalaqaListItemEntity>>>?
  _halaqaSubscription;

  HalaqaBloc({
    required WatchHalaqasUseCase watchHalaqas,
    required FetchMoreHalaqasUseCase fetchMoreHalaqas,
    required GetHalaqaById getHalaqaById,
    required UpsertHalaqa upsertHalaqa,
    required DeleteHalaqaUseCase deleteHalaqa,
    required SetHalaqaStatusUseCase setHalaqaStatus,
  }) : _watchHalaqas = watchHalaqas,
       _fetchMoreHalaqas = fetchMoreHalaqas,
       _upsertHalaqa = upsertHalaqa,
       _deleteHalaqa = deleteHalaqa,
       _getHalaqaById = getHalaqaById,
       _setHalaqaStatus = setHalaqaStatus,

       super(const HalaqaState()) {
    // Register event handlers with concurrency transformers for robustness.
    on<WatchHalaqasStarted>(_onWatchStarted, transformer: restartable());
    on<HalaqasRefreshed>(_onRefreshed, transformer: restartable());
    on<_HalaqasStreamUpdated>(_onStreamUpdated);
    on<MoreHalaqasLoaded>(_onLoadMore, transformer: droppable());
    on<HalaqaUpserted>(_onUpsert, transformer: droppable());
    on<HalaqaDeleted>(_onDelete, transformer: droppable());
    on<HalaqaDetailsFetched>(_onFetchDetails, transformer: restartable());
    on<HalaqaStatusChanged>(_onStatusChange, transformer: droppable());
  }

  @override
  Future<void> close() {
    _halaqaSubscription?.cancel();
    return super.close();
  }

  void _onWatchStarted(WatchHalaqasStarted event, Emitter<HalaqaState> emit) {
    if (state.status == HalaqaStatus.initial) {
      emit(state.copyWith(status: HalaqaStatus.loading));
    }
    print('WatchHalaqasStarted event received. Initializing halaqa stream.');
    _halaqaSubscription?.cancel();
    _halaqaSubscription = _watchHalaqas(
      const WatchHalaqasParams(),
    ).listen((update) => add(_HalaqasStreamUpdated(update)));
  }

  void _onRefreshed(HalaqasRefreshed event, Emitter<HalaqaState> emit) {
    // Simply call the use case again with `forceRefresh: true`.
    _halaqaSubscription?.cancel();
    print("Refreshing halaqas list...");
    _halaqaSubscription = _watchHalaqas(
      const WatchHalaqasParams(forceRefresh: true),
    ).listen((update) => add(_HalaqasStreamUpdated(update)));
  }

  void _onStreamUpdated(
    _HalaqasStreamUpdated event,
    Emitter<HalaqaState> emit,
  ) {
    event.update.fold(
      (failure) =>
          emit(state.copyWith(status: HalaqaStatus.failure, failure: failure)),
      (halaqas) =>
          emit(state.copyWith(status: HalaqaStatus.success, halaqas: halaqas)),
    );
  }

  Future<void> _onLoadMore(
    MoreHalaqasLoaded event,
    Emitter<HalaqaState> emit,
  ) async {
    if (!state.hasMorePages) return;
    emit(state.copyWith(isLoadingMore: true, clearListFailure: true));

    final nextPage = state.currentPage + 1;
    final result = await _fetchMoreHalaqas(nextPage);

    result.fold(
      (failure) => emit(state.copyWith(isLoadingMore: false, failure: failure)),
      (newItems) => emit(
        state.copyWith(
          isLoadingMore: false,
          currentPage: nextPage,
          hasMorePages: false,
        ),
      ),
    );
  }

  /// Handles the fetching of a single halaqa's detailed profile.
  Future<void> _onFetchDetails(
    HalaqaDetailsFetched event,
    Emitter<HalaqaState> emit,
  ) async {
    // 1. Emit a loading state specifically for the details view.
    //    This does not affect the main list's status.
    emit(
      state.copyWith(
        detailsStatus: HalaqaDetailsStatus.loading,
        clearDetailsFailure: true,
      ),
    );

    // 2. Call the use case to fetch the data.
    final result = await _getHalaqaById(event.halaqaId);

    // 3. Fold the result and emit either a success or failure state.
    result.fold(
      (failure) => emit(
        state.copyWith(
          detailsStatus: HalaqaDetailsStatus.failure,
          detailsFailure: failure,
        ),
      ),
      (halaqaDetails) => emit(
        state.copyWith(
          detailsStatus: HalaqaDetailsStatus.success,
          selectedHalaqa: halaqaDetails,
        ),
      ),
    );
  }

  /// Handles the creation or update of a halaqa.
  Future<void> _onUpsert(
    HalaqaUpserted event,
    Emitter<HalaqaState> emit,
  ) async {
    emit(
      state.copyWith(
        submissionStatus: HalaqaSubmissionStatus.submitting,
        clearSubmissionFailure: true,
      ),
    );

    final result = await _upsertHalaqa(event.halaqa);

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: HalaqaSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) {
        // On success, the list will update automatically via the stream.
        // We just need to signal that the submission process is complete.
        emit(state.copyWith(submissionStatus: HalaqaSubmissionStatus.success));
      },
    );
  }

  /// Handles the deletion of a halaqa.
  Future<void> _onDelete(HalaqaDeleted event, Emitter<HalaqaState> emit) async {
    emit(state.copyWith(submissionStatus: HalaqaSubmissionStatus.submitting));

    final result = await _deleteHalaqa(event.halaqaId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: HalaqaSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) => emit(
        state.copyWith(submissionStatus: HalaqaSubmissionStatus.success),
      ),
    );
  }

  /// Handles changing a halaqa's status (e.g., active, suspended).
  Future<void> _onStatusChange(
    HalaqaStatusChanged event,
    Emitter<HalaqaState> emit,
  ) async {
    emit(state.copyWith(submissionStatus: HalaqaSubmissionStatus.submitting));

    final result = await _setHalaqaStatus(
      SetHalaqaStatusParams(
        halaqaId: event.halaqaId,
        newStatus: event.newStatus,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: HalaqaSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) => emit(
        state.copyWith(submissionStatus: HalaqaSubmissionStatus.success),
      ),
    );
  }
}
