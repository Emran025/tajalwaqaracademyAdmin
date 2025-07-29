import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
// import 'package:injectable/injectable.dart';


import '../../../../core/errors/error_model.dart';
import '../../../../core/models/active_status.dart';
import '../../domain/entities/teacher_entity.dart';
import '../../domain/entities/teacher_list_item_entity.dart';
import '../../domain/usecases/delete_teacher_usecase.dart';
import '../../domain/usecases/fetch_more_teachers_usecase.dart';
import '../../domain/usecases/get_teacher_by_id.dart';
import '../../domain/usecases/get_teachers.dart';
import '../../domain/usecases/set_teacher_status_params.dart';
import '../../domain/usecases/upsert_teacher_usecase.dart';

part 'teacher_event.dart';
part 'teacher_state.dart';

// @injectable
class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final WatchTeachersUseCase _watchTeachers;
  final FetchMoreTeachersUseCase _fetchMoreTeachers;
  final GetTeacherById _getTeacherById;
  final UpsertTeacher _upsertTeacher;
  final DeleteTeacherUseCase _deleteTeacher;
  final SetTeacherStatusUseCase _setTeacherStatus;

  StreamSubscription<Either<Failure, List<TeacherListItemEntity>>>?
  _teacherSubscription;

  TeacherBloc({
    required WatchTeachersUseCase watchTeachers,
    required FetchMoreTeachersUseCase fetchMoreTeachers,
    required GetTeacherById getTeacherById,
    required UpsertTeacher upsertTeacher,
    required DeleteTeacherUseCase deleteTeacher,
    required SetTeacherStatusUseCase setTeacherStatus,

  }) : _watchTeachers = watchTeachers,
       _fetchMoreTeachers = fetchMoreTeachers,
       _upsertTeacher = upsertTeacher,
       _deleteTeacher = deleteTeacher,
       _getTeacherById = getTeacherById,
       _setTeacherStatus = setTeacherStatus ,

       super(const TeacherState()) {
    // Register event handlers with concurrency transformers for robustness.
    on<WatchTeachersStarted>(_onWatchStarted, transformer: restartable());
    on<TeachersRefreshed>(_onRefreshed, transformer: restartable());
    on<_TeachersStreamUpdated>(_onStreamUpdated);
    on<MoreTeachersLoaded>(_onLoadMore, transformer: droppable());
    on<TeacherUpserted>(_onUpsert, transformer: droppable());
    on<TeacherDeleted>(_onDelete, transformer: droppable());
    on<TeacherDetailsFetched>(_onFetchDetails, transformer: restartable());
    on<TeacherStatusChanged>(_onStatusChange, transformer: droppable());



  }

  @override
  Future<void> close() {
    _teacherSubscription?.cancel();
    return super.close();
  }

  void _onWatchStarted(WatchTeachersStarted event, Emitter<TeacherState> emit) {
    if (state.status == TeacherStatus.initial) {
      emit(state.copyWith(status: TeacherStatus.loading));
    }
    print('WatchTeachersStarted event received. Initializing teacher stream.');
    _teacherSubscription?.cancel();
    _teacherSubscription = _watchTeachers(
      const WatchTeachersParams(),
    ).listen((update) => add(_TeachersStreamUpdated(update)));
  }

  void _onRefreshed(TeachersRefreshed event, Emitter<TeacherState> emit) {
    // Simply call the use case again with `forceRefresh: true`.
    _teacherSubscription?.cancel();
    print("Refreshing teachers list...");
    _teacherSubscription = _watchTeachers(
      const WatchTeachersParams(forceRefresh: true),
    ).listen((update) => add(_TeachersStreamUpdated(update)));
  }

  void _onStreamUpdated(
    _TeachersStreamUpdated event,
    Emitter<TeacherState> emit,
  ) {
    event.update.fold(
      (failure) =>
          emit(state.copyWith(status: TeacherStatus.failure, failure: failure)),
      (teachers) => emit(
        state.copyWith(status: TeacherStatus.success, teachers: teachers),
      ),
    );
  }

  Future<void> _onLoadMore(
    MoreTeachersLoaded event,
    Emitter<TeacherState> emit,
  ) async {
    if (!state.hasMorePages) return;
    emit(state.copyWith(isLoadingMore: true, clearListFailure: true));

    final nextPage = state.currentPage + 1;
    final result = await _fetchMoreTeachers(
      nextPage,
    );

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

    /// Handles the fetching of a single teacher's detailed profile.
  Future<void> _onFetchDetails(
    TeacherDetailsFetched event,
    Emitter<TeacherState> emit,
  ) async {
    // 1. Emit a loading state specifically for the details view.
    //    This does not affect the main list's status.
    emit(state.copyWith(
      detailsStatus: TeacherDetailsStatus.loading,
      clearDetailsFailure: true,
    ));

    // 2. Call the use case to fetch the data.
    final result = await _getTeacherById(event.teacherId);

    // 3. Fold the result and emit either a success or failure state.
    result.fold(
      (failure) => emit(state.copyWith(
        detailsStatus: TeacherDetailsStatus.failure,
        detailsFailure: failure,
      )),
      (teacherDetails) => emit(state.copyWith(
        detailsStatus: TeacherDetailsStatus.success,
        selectedTeacher: teacherDetails,
      )),
    );
  }

  
  /// Handles the creation or update of a teacher.
  Future<void> _onUpsert(
    TeacherUpserted event,
    Emitter<TeacherState> emit,
  ) async {
    emit(state.copyWith(
      submissionStatus: TeacherSubmissionStatus.submitting,
      clearSubmissionFailure: true,
    ));

    final result = await _upsertTeacher(event.teacher);

    result.fold(
      (failure) => emit(state.copyWith(
        submissionStatus: TeacherSubmissionStatus.failure,
        submissionFailure: failure,
      )),
      (_) {
        // On success, the list will update automatically via the stream.
        // We just need to signal that the submission process is complete.
        emit(state.copyWith(submissionStatus: TeacherSubmissionStatus.success));
      },
    );
  }

  /// Handles the deletion of a teacher.
  Future<void> _onDelete(
    TeacherDeleted event,
    Emitter<TeacherState> emit,
  ) async {
    emit(state.copyWith(submissionStatus: TeacherSubmissionStatus.submitting));

    final result = await _deleteTeacher(event.teacherId);

    result.fold(
      (failure) => emit(state.copyWith(
        submissionStatus: TeacherSubmissionStatus.failure,
        submissionFailure: failure,
      )),
      (_) => emit(state.copyWith(submissionStatus: TeacherSubmissionStatus.success)),
    );
  }

  /// Handles changing a teacher's status (e.g., active, suspended).
  Future<void> _onStatusChange(
    TeacherStatusChanged event,
    Emitter<TeacherState> emit,
  ) async {
    emit(state.copyWith(submissionStatus: TeacherSubmissionStatus.submitting));

    final result = await _setTeacherStatus(
      SetTeacherStatusParams(
        teacherId: event.teacherId,
        newStatus: event.newStatus,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        submissionStatus: TeacherSubmissionStatus.failure,
        submissionFailure: failure,
      )),
      (_) => emit(state.copyWith(submissionStatus: TeacherSubmissionStatus.success)),
    );
  }


}
