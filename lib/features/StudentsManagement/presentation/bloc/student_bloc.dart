import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
// import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/active_status.dart';
import '../../../../core/models/report_frequency.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/student_info_entity.dart';
import '../../domain/entities/student_list_item_entity.dart';
import '../../domain/usecases/delete_student_usecase.dart';
import '../../domain/usecases/fetch_more_student_usecase.dart';
import '../../domain/usecases/generate_follow_up_report_use_case.dart';
import '../../domain/usecases/get_filtered_students.dart';
import '../../domain/usecases/get_student_by_id.dart';
import '../../domain/usecases/get_students.dart';
import '../../domain/usecases/set_student_status_params.dart';
import '../../domain/usecases/upsert_student_usecase.dart';
import '../view_models/follow_up_report_bundle_entity.dart';

part 'student_event.dart';
part 'student_state.dart';

// @injectable
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final WatchStudentsUseCase _watchStudentsUC;
  final FetchMoreStudentsUseCase _fetchMoreStudentsUC;
  final FetchFilteredStudentsUseCase _fetchFilteredStudentsUC;
  final GetStudentById _getStudentByIdUC;
  final UpsertStudent _upsertStudentUC;
  final DeleteStudentUseCase _deleteStudentUC;
  final SetStudentStatusUseCase _setStudentStatusUC;
  final GenerateFollowUpReportUseCase _generateFollowUpReportUC;

  StreamSubscription<Either<Failure, List<StudentListItemEntity>>>?
  _studentSubscription;

  StudentBloc({
    required WatchStudentsUseCase watchStudents,
    required FetchMoreStudentsUseCase fetchMoreStudents,
    required FetchFilteredStudentsUseCase fetchFilteredStudents,
    required GetStudentById getStudentById,
    required UpsertStudent upsertStudent,
    required DeleteStudentUseCase deleteStudent,
    required SetStudentStatusUseCase setStudentStatus,
    required GenerateFollowUpReportUseCase generateFollowUpReportUC,
  }) : _watchStudentsUC = watchStudents,
       _fetchMoreStudentsUC = fetchMoreStudents,
       _fetchFilteredStudentsUC = fetchFilteredStudents,
       _upsertStudentUC = upsertStudent,
       _deleteStudentUC = deleteStudent,
       _getStudentByIdUC = getStudentById,
       _setStudentStatusUC = setStudentStatus,
       _generateFollowUpReportUC = generateFollowUpReportUC,

       super(const StudentState()) {
    // Register event handlers with concurrency transformers for robustness.
    on<WatchStudentsStarted>(_onWatchStarted, transformer: restartable());
    on<StudentsRefreshed>(_onRefreshed, transformer: restartable());
    on<_StudentsStreamUpdated>(_onStreamUpdated);
    on<MoreStudentsLoaded>(_onLoadMore, transformer: droppable());
    on<StudentUpserted>(_onUpsert, transformer: droppable());
    on<StudentDeleted>(_onDelete, transformer: droppable());
    on<StudentDetailsFetched>(_onFetchDetails, transformer: restartable());
    on<FilteredStudents>(_onFetchFilteredStudents, transformer: restartable());
    on<StudentStatusChanged>(_onStatusChange, transformer: droppable());
    on<FollowUpReportFetched>(_onFetchReport, transformer: droppable());
  }

  @override
  Future<void> close() {
    _studentSubscription?.cancel();
    return super.close();
  }

  void _onWatchStarted(WatchStudentsStarted event, Emitter<StudentState> emit) {
    if (state.status == StudentStatus.initial) {
      emit(state.copyWith(status: StudentStatus.loading));
    }
    print('WatchStudentsStarted event received. Initializing student stream.');
    _studentSubscription?.cancel();
    _studentSubscription = _watchStudentsUC(
      const WatchStudentsParams(),
    ).listen((update) => add(_StudentsStreamUpdated(update)));
  }

  void _onRefreshed(StudentsRefreshed event, Emitter<StudentState> emit) {
    // Simply call the use case again with `forceRefresh: true`.
    _studentSubscription?.cancel();
    print("Refreshing students list...");
    _studentSubscription = _watchStudentsUC(
      const WatchStudentsParams(forceRefresh: true),
    ).listen((update) => add(_StudentsStreamUpdated(update)));
  }

  void _onStreamUpdated(
    _StudentsStreamUpdated event,
    Emitter<StudentState> emit,
  ) {
    event.update.fold(
      (failure) =>
          emit(state.copyWith(status: StudentStatus.failure, failure: failure)),
      (students) => emit(
        state.copyWith(status: StudentStatus.success, students: students),
      ),
    );
  }

  Future<void> _onLoadMore(
    MoreStudentsLoaded event,
    Emitter<StudentState> emit,
  ) async {
    if (!state.hasMorePages) return;
    emit(state.copyWith(isLoadingMore: true, clearListFailure: true));

    final nextPage = state.currentPage + 1;
    final result = await _fetchMoreStudentsUC(nextPage);

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

  /// Handles the fetching of a single student's detailed profile.
  Future<void> _onFetchDetails(
    StudentDetailsFetched event,
    Emitter<StudentState> emit,
  ) async {
    // 1. Emit a loading state specifically for the details view.
    //    This does not affect the main list's status.
    emit(
      state.copyWith(
        detailsStatus: StudentInfoStatus.loading,
        clearDetailsFailure: true,
      ),
    );

    // 2. Call the use case to fetch the data.
    final result = await _getStudentByIdUC(event.studentId);

    // 3. Fold the result and emit either a success or failure state.
    result.fold(
      (failure) => emit(
        state.copyWith(
          detailsStatus: StudentInfoStatus.failure,
          detailsFailure: failure,
        ),
      ),
      (studentDetails) => emit(
        state.copyWith(
          detailsStatus: StudentInfoStatus.success,
          selectedStudent: studentDetails,
        ),
      ),
    );
  }
  
  /// Handles the fetching of a single student's detailed profile.
  Future<void> _onFetchFilteredStudents(
    FilteredStudents event,
    Emitter<StudentState> emit,
  ) async {
    // 1. Emit a loading state specifically for the details view.
    //    This does not affect the main list's status.
    emit(
      state.copyWith(
        filteredStudentsStatus: StudentStatus.loading,
        clearFilteredStudentsFailure: true,
      ),
    );

    final result = await _fetchFilteredStudentsUC(GetFilteredStudentsParams
    (
      status: event.status,
      halaqaId: event.halaqaId,
      trackDate: event.trackDate,
      frequencyCode: event.frequencyCode,
    ));

    // 3. Fold the result and emit either a success or failure state.
    result.fold(
      (failure) => emit(
        state.copyWith(
          filteredStudentsStatus: StudentStatus.failure,
          filteredStudentsFailure: failure,
        ),
      ),
      (filteredStudents) => emit(
        state.copyWith(
          filteredStudentsStatus: StudentStatus.success,
          filteredStudents: filteredStudents,
        ),
      ),
    );
  }

  /// Handles the creation or update of a student.
  Future<void> _onUpsert(
    StudentUpserted event,
    Emitter<StudentState> emit,
  ) async {
    emit(
      state.copyWith(
        submissionStatus: StudentSubmissionStatus.submitting,
        clearSubmissionFailure: true,
      ),
    );

    final result = await _upsertStudentUC(event.student);

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: StudentSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) {
        // On success, the list will update automatically via the stream.
        // We just need to signal that the submission process is complete.
        emit(state.copyWith(submissionStatus: StudentSubmissionStatus.success));
      },
    );
  }

  /// Handles the deletion of a student.
  Future<void> _onDelete(
    StudentDeleted event,
    Emitter<StudentState> emit,
  ) async {
    emit(state.copyWith(submissionStatus: StudentSubmissionStatus.submitting));

    final result = await _deleteStudentUC(event.studentId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: StudentSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) => emit(
        state.copyWith(submissionStatus: StudentSubmissionStatus.success),
      ),
    );
  }

  /// Handles changing a student's status (e.g., active, suspended).
  Future<void> _onStatusChange(
    StudentStatusChanged event,
    Emitter<StudentState> emit,
  ) async {
    emit(state.copyWith(submissionStatus: StudentSubmissionStatus.submitting));

    final result = await _setStudentStatusUC(
      SetStudentStatusParams(
        studentId: event.studentId,
        newStatus: event.newStatus,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: StudentSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) => emit(
        state.copyWith(submissionStatus: StudentSubmissionStatus.success),
      ),
    );
  }

  Future<void> _onFetchReport(
    FollowUpReportFetched event,
    Emitter<StudentState> emit,
  ) async {
    emit(
      state.copyWith(
        followUpReportStatus: FollowUpReportStatus.loading,
        clearFollowUpReportFailure: true,
      ),
    );

    final result = await _generateFollowUpReportUC(event.studentId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          followUpReportStatus: FollowUpReportStatus.failure,
          detailsFailure: failure,
        ),
      ),
      (followUpReport) {
        print(followUpReport);
        emit(
          state.copyWith(
            followUpReportStatus: FollowUpReportStatus.success,
            followUpReport: followUpReport,
          ),
        );
      },
    );
  }

}
