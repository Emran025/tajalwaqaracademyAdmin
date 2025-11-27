
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart'; // Import collection package for firstWhereOrNull
import 'package:uuid/uuid.dart';
import '../../../../core/constants/tracking_unit_detail.dart';
import '../../../../core/models/mistake_type.dart';
import '../../../../core/utils/data_status.dart';

// Import your existing domain entities
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/tracking_detail_entity.dart';
import 'package:tajalwaqaracademy/core/models/tracking_type.dart';

// Import our new domain entities and use cases
import '../../domain/entities/mistake.dart';
import '../../domain/usecases/get_all_mistakes.dart';
import '../../domain/usecases/get_or_create_today_tracking.dart';
import '../../domain/usecases/save_task_progress.dart';
import '../../domain/usecases/finalize_session.dart';
part 'tracking_session_event.dart';
part 'tracking_session_state.dart';

class TrackingSessionBloc
    extends Bloc<TrackingSessionEvent, TrackingSessionState> {
  final GetOrCreateTodayTrackingDetails _getOrCreateTodayTrackingDetails;
  final SaveTaskProgress _saveTaskProgress;
  final FinalizeSession _finalizeSession;
  final GetAllMistakes _getAllMistakes;
  TrackingSessionBloc({
    required GetOrCreateTodayTrackingDetails getOrCreateTodayTrackingDetails,
    required SaveTaskProgress saveTaskProgress,
    required FinalizeSession finalizeSession,
    required GetAllMistakes getAllMistakes,
  }) : _getOrCreateTodayTrackingDetails = getOrCreateTodayTrackingDetails,
       _saveTaskProgress = saveTaskProgress,
       _finalizeSession = finalizeSession,
       _getAllMistakes = getAllMistakes,
       super(const TrackingSessionState(enrollmentId: "-1")) {
    on<SessionStarted>(_onSessionStarted);
    on<TaskTypeChanged>(_onTaskTypeChanged);
    on<WordTappedForMistake>(_onWordTappedForMistake);

    on<MistakeCategorized>(_onMistakeCategorized);
    on<QualityRatingChanged>(_onQualityRatingChanged);
    on<TaskNotesChanged>(_onTaskNotesChanged);
    on<TaskReportSaved>(_onTaskReportSaved);
    on<FinalSessionReportSaved>(_onFinalSessionReportSaved);
    on<HistoricalMistakesRequested>(_onHistoricalMistakesRequested);
    on<RecitationRangeEnded>(_onRecitationRangeEnded);
  }
  Future<void> _onSessionStarted(
    SessionStarted event,
    Emitter<TrackingSessionState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DataStatus.loading,
        enrollmentId: event.enrollmentId,
      ),
    );

    // Using the updated use case
    final result = await _getOrCreateTodayTrackingDetails(
      GetOrCreateTodayTrackingDetailsParams(enrollmentId: event.enrollmentId),
    );
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: DataStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (trackingData) {
        emit(
          state.copyWith(
            status: DataStatus.success,
            taskProgress: trackingData,
          ),
        );
      },
    );
  }

  void _onTaskTypeChanged(
    TaskTypeChanged event,
    Emitter<TrackingSessionState> emit,
  ) {
    emit(state.copyWith(status: DataStatus.loading));
    emit(
      state.copyWith(
        currentTaskType: event.newType,
        status: DataStatus.success,
      ),
    );
  }

  void _onMistakeCategorized(
    MistakeCategorized event,
    Emitter<TrackingSessionState> emit,
  ) async {
    final currentDetail = state.currentTaskDetail;

    if (currentDetail == null) return;

    // Manually rebuild the list of mistakes
    final updatedMistakes = currentDetail.mistakes.map((mistake) {
      if (mistake.id == event.mistakeId.toString()) {
        return Mistake(
          id: mistake.id,
          trackingDetailId: mistake.trackingDetailId,
          ayahIdQuran: mistake.ayahIdQuran,
          wordIndex: mistake.wordIndex,
          mistakeType: event.newMistakeType,
        );
      }
      return mistake;
    }).toList();
    final updatedDetail = TrackingDetailEntity(
      id: currentDetail.id,
      uuid: currentDetail.uuid,
      trackingId: currentDetail.trackingId,
      trackingTypeId: currentDetail.trackingTypeId,
      fromTrackingUnitId: currentDetail.fromTrackingUnitId,
      toTrackingUnitId: currentDetail.toTrackingUnitId,
      actualAmount: currentDetail.actualAmount,
      comment: currentDetail.comment,
      status: currentDetail.status,
      score: currentDetail.score,
      gap: currentDetail.gap,
      createdAt: currentDetail.createdAt,
      updatedAt: currentDetail.updatedAt,
      mistakes: updatedMistakes, // The new list of mistakes
    );

    await _updateStateWithNewDetail(emit, updatedDetail);
  }

  void _onQualityRatingChanged(
    QualityRatingChanged event,
    Emitter<TrackingSessionState> emit,
  ) async {
    final currentDetail = state.currentTaskDetail;
    if (currentDetail == null) return;

    // Manually rebuild the TrackingDetailEntity with the new score
    final updatedDetail = TrackingDetailEntity(
      id: currentDetail.id,
      uuid: currentDetail.uuid,
      trackingId: currentDetail.trackingId,
      trackingTypeId: currentDetail.trackingTypeId,
      fromTrackingUnitId: currentDetail.fromTrackingUnitId,
      toTrackingUnitId: currentDetail.toTrackingUnitId,
      actualAmount: currentDetail.actualAmount,
      comment: currentDetail.comment,
      status: currentDetail.status,
      score: event.newRating,
      gap: currentDetail.gap,
      createdAt: currentDetail.createdAt,
      updatedAt: currentDetail.updatedAt,
      mistakes: currentDetail.mistakes,
    );

    await _updateStateWithNewDetail(emit, updatedDetail);
  }

  void _onTaskNotesChanged(
    TaskNotesChanged event,
    Emitter<TrackingSessionState> emit,
  ) async {
    final currentDetail = state.currentTaskDetail;
    if (currentDetail == null) return;

    // Manually rebuild the TrackingDetailEntity with the new comment
    final updatedDetail = TrackingDetailEntity(
      id: currentDetail.id,
      uuid: currentDetail.uuid,
      trackingId: currentDetail.trackingId,
      trackingTypeId: currentDetail.trackingTypeId,
      fromTrackingUnitId: currentDetail.fromTrackingUnitId,
      toTrackingUnitId: currentDetail.toTrackingUnitId,
      actualAmount: currentDetail.actualAmount,
      comment: event.newNotes, // The only changed value
      status: currentDetail.status, // The only changed value
      score: currentDetail.score,
      gap: currentDetail.gap,
      createdAt: currentDetail.createdAt,
      updatedAt: currentDetail.updatedAt,
      mistakes: currentDetail.mistakes,
    );

    await _updateStateWithNewDetail(emit, updatedDetail);
  }

  // The helper method remains the same and is still very useful.
  Future<void> _updateStateWithNewDetail(
    Emitter<TrackingSessionState> emit,
    TrackingDetailEntity updatedDetail,
  ) async {
    final updatedProgress = Map<TrackingType, TrackingDetailEntity>.from(
      state.taskProgress,
    );

    updatedProgress[state.currentTaskType] = updatedDetail;
    emit(state.copyWith(taskProgress: updatedProgress));
    // Then, call the use case to persist this final entity to the database.
    emit(state.copyWith(status: DataStatus.loading));
    final result = await _saveTaskProgress(
      SaveTaskProgressParams(detail: updatedDetail),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DataStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: DataStatus.success)),
    );
  }

  void _onWordTappedForMistake(
    WordTappedForMistake event,
    Emitter<TrackingSessionState> emit,
  ) async {
    final currentTaskDetail = state.currentTaskDetail;

    if (currentTaskDetail == null) return;

    final List<Mistake> updatedMistakes = List.from(currentTaskDetail.mistakes);
    final existingMistake = updatedMistakes.firstWhereOrNull(
      (m) => m.ayahIdQuran == event.ayahId && m.wordIndex == event.wordIndex,
    );

    if (existingMistake != null) {
      updatedMistakes.remove(existingMistake);
    } else {
      final newMistake = Mistake(
        id: const Uuid().v4(),
        trackingDetailId: "${currentTaskDetail.id}",
        ayahIdQuran: event.ayahId,
        wordIndex: event.wordIndex,
        mistakeType: event.newMistakeType,
      );
      updatedMistakes.add(newMistake);
    }

    final updatedTaskDetail = TrackingDetailEntity(
      id: currentTaskDetail.id,
      uuid: currentTaskDetail.uuid,
      trackingId: currentTaskDetail.trackingId,
      trackingTypeId: currentTaskDetail.trackingTypeId,
      fromTrackingUnitId: currentTaskDetail.fromTrackingUnitId,
      toTrackingUnitId: currentTaskDetail.toTrackingUnitId,
      actualAmount: currentTaskDetail.actualAmount,
      comment: currentTaskDetail.comment,
      status: currentTaskDetail.status,
      score: currentTaskDetail.score,
      gap: currentTaskDetail.gap,
      createdAt: currentTaskDetail.createdAt,
      updatedAt: currentTaskDetail.updatedAt,
      mistakes: updatedMistakes, // <-- PASS THE UPDATED MISTAKES LIST
    );
    // ========================================================

    // await _updateStateWithNewDetail(emit, updatedTaskDetail);

    final updatedProgress = Map<TrackingType, TrackingDetailEntity>.from(
      state.taskProgress,
    );

    updatedProgress[state.currentTaskType] = updatedTaskDetail;

    emit(state.copyWith(taskProgress: updatedProgress));
  }

  // add report of the traking Type task and chang the statuse frome 'draft' to `completed`

  Future<void> _onTaskReportSaved(
    TaskReportSaved event,
    Emitter<TrackingSessionState> emit,
  ) async {
    final currentDetail = state.currentTaskDetail;
    if (currentDetail == null) return;

    // Create the final entity to save. Note that the status is still 'draft' here.
    // The status only changes upon finalization of the whole day's report.
    final finalDetailToSave = TrackingDetailEntity(
      id: currentDetail.id,
      uuid: currentDetail.uuid, // Pass UUID
      trackingId: currentDetail.trackingId,
      trackingTypeId: currentDetail.trackingTypeId,
      fromTrackingUnitId: currentDetail.fromTrackingUnitId,
      toTrackingUnitId: currentDetail.toTrackingUnitId,
      actualAmount: currentDetail.actualAmount,
      comment: event.notes,
      score: event.rating,
      status: event.isFinalizingTask
          ? 'completed'
          : currentDetail.status, // Keep the current status ('draft')
      gap: currentDetail.gap,
      createdAt: currentDetail.createdAt,
      updatedAt: DateTime.now(), // Update the timestamp
      mistakes: currentDetail.mistakes,
    );

    _updateStateWithNewDetail(emit, finalDetailToSave);

    emit(state.copyWith(status: DataStatus.loading));
    final result = await _saveTaskProgress(
      SaveTaskProgressParams(detail: finalDetailToSave),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DataStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: DataStatus.success)),
    );
  }

  // _onFinalSessionReportSaved remains the same as it doesn't modify entities.
  Future<void> _onFinalSessionReportSaved(
    FinalSessionReportSaved event,
    Emitter<TrackingSessionState> emit,
  ) async {
    // The parent tracking ID is what we need to finalize.
    // It's the same for all details in the current session.
    final parentTrackingId = int.tryParse(
      state.currentTaskDetail?.trackingId ?? '1',
    );
    if (parentTrackingId == null) return;

    emit(state.copyWith(status: DataStatus.loading));
    bool hasNoDetails = true;

    state.taskProgress.forEach((type, detail) {
      detail.status == 'completed' ? hasNoDetails = false : null;
    });

    if (hasNoDetails) return;

    final result = await _finalizeSession(
      FinalizeSessionParams(
        trackingId: parentTrackingId,
        finalNotes: event.generalNotes,
        behaviorScore: int.tryParse(event.behavioralNotes) ?? 0,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: DataStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(status: DataStatus.success));
        // we have to add new Session Started event from here if we didnot get out the Session Main page
      },
    );
  }

  void _onRecitationRangeEnded(
    RecitationRangeEnded event,
    Emitter<TrackingSessionState> emit,
  ) async {
    final currentDetail = state.currentTaskDetail;
    if (currentDetail == null) return;

    // Create a new TrackingUnitDetail for the end point
    //  double gap = double.parse("${event.pageCount}.${event.ayah}");

    int gapPageCount = event.pageNumber;

    int addedNumber = 0;

    while (gapPageCount > currentDetail.toTrackingUnitId.toPage &&
        trackingUnitDetail[(currentDetail.toTrackingUnitId.id - 1) +
                    addedNumber]
                .unitId ==
            currentDetail.toTrackingUnitId.unitId) {
      gapPageCount -=
          (trackingUnitDetail[(currentDetail.toTrackingUnitId.id - 1) +
                  addedNumber]
              .toAyah -
          trackingUnitDetail[(currentDetail.toTrackingUnitId.id - 1) +
                  addedNumber]
              .fromAyah);
      ++addedNumber;
    }
    final newToTrackingUnitId =
        trackingUnitDetail[(currentDetail.toTrackingUnitId.id - 1) +
            addedNumber];
    final gap = double.parse("$gapPageCount.${event.ayah}");

    // Manually rebuild the entity with the new `toTrackingUnitId`
    final updatedDetail = TrackingDetailEntity(
      id: currentDetail.id,
      uuid: currentDetail.uuid,
      trackingId: currentDetail.trackingId,
      trackingTypeId: currentDetail.trackingTypeId,
      fromTrackingUnitId: currentDetail.fromTrackingUnitId,
      toTrackingUnitId: newToTrackingUnitId,
      actualAmount: currentDetail.actualAmount,
      comment: currentDetail.comment,
      status: currentDetail.status,
      score: currentDetail.score,
      gap: gap,
      createdAt: currentDetail.createdAt,
      updatedAt: currentDetail.updatedAt,
      mistakes: currentDetail.mistakes,
    );
    await _updateStateWithNewDetail(emit, updatedDetail);
  }

  // In TrackingSessionBloc
  Future<void> _onHistoricalMistakesRequested(
    HistoricalMistakesRequested event,
    Emitter<TrackingSessionState> emit,
  ) async {
    emit(state.copyWith(historicalMistakesStatus: DataStatus.loading));

    // Call the UseCase without a type to fetch all mistakes.
    final result = await _getAllMistakes(
      GetAllMistakesParams(
        enrollmentId: state.enrollmentId,
        // No type specified, so we get all types.
        // We can pass page filters from the event if needed.
        fromPage: event.fromPage,
        toPage: event.toPage,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          historicalMistakesStatus: DataStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (allMistakesList) {
        emit(
          state.copyWith(
            historicalMistakesStatus: DataStatus.success,
            historicalMistakes: allMistakesList,
          ),
        );
      },
    );
  }
}
