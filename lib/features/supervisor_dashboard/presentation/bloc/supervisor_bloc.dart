// bloc/student_timeline_bloc.dart

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/applicant_entity.dart';

import '../../data/models/composite_performance_data.dart';
import '../../domain/entities/chart_filter_entity.dart';
import '../../domain/entities/counts_delta_entity.dart';
import '../../domain/entities/timeline_entity.dart';
import '../../domain/factories/chart_factory.dart';
import '../../domain/usecases/applicants_use_case.dart';
import '../../domain/usecases/approve_applicant_usecase.dart';
import '../../domain/usecases/get_applicant_profile_usecase.dart';
import '../../domain/usecases/get_date_range_use_case.dart';
import '../../domain/usecases/get_entities_counts_use_case.dart';
import '../../domain/usecases/get_timeline_use_case.dart';
import '../../domain/usecases/reject_applicant_usecase.dart';
import '../../domain/entities/applicant_profile_entity.dart';

part 'supervisor_event.dart';
part 'supervisor_state.dart';

class SupervisorBloc extends Bloc<SupervisorEvent, SupervisorState> {
  final GetEntitiesCountsUseCase getEntitiesCountsUseCase;
  final GetTimelineUseCase getTimelineUseCase;
  final GetDateRangeUseCase getDateRangeUseCase;
  final GetApplicantsUseCase getApplicantsUC;
  final GetApplicantProfileUseCase getApplicantProfileUC;
  final ApproveApplicantUseCase approveApplicantUC;
  final RejectApplicantUseCase rejectApplicantUC;

  SupervisorBloc({
    required this.getEntitiesCountsUseCase,
    required this.getTimelineUseCase,
    required this.getDateRangeUseCase,
    required this.getApplicantsUC,
    required this.getApplicantProfileUC,
    required this.approveApplicantUC,
    required this.rejectApplicantUC,
  }) : super(SupervisorInitial()) {
    on<LoadCountsDeltaEntity>(_onLoadCountsDeltaEntity);
    on<LoadTimeline>(_onLoadTimeline);
    on<UpdateChartFilter>(_onUpdateChartFilter);
    on<ApplicantsFetched>(_onApplicantsFetched, transformer: restartable());
    on<MoreApplicantsLoaded>(_onMoreApplicantsLoaded, transformer: droppable());
    on<ApplicantProfileFetched>(_onApplicantProfileFetched);
    on<ApproveApplicant>(_onApproveApplicant);
    on<RejectApplicant>(_onRejectApplicant);
    on<ClearMessage>(_onClearMessage);
  }

  Future<void> _onClearMessage(
    ClearMessage event,
    Emitter<SupervisorState> emit,
  ) async {
    final currentState = state;
    if (currentState is SupervisorLoaded) {
      emit(currentState.copyWith(
        message: null,
        errorMessage: null,
        rejectStatus: ActionStatus.initial,
      ));
    }
  }

  Future<void> _onLoadTimeline(
    LoadTimeline event,
    Emitter<SupervisorState> emit,
  ) async {
    if (isClosed) return;

    final currentState = state;
    if (currentState is! SupervisorLoaded) return;

    emit(SupervisorLoading());

    try {
      final dateRangeResult = await getDateRangeUseCase(
        event.filter.entityType,
      );

      if (isClosed) return;

      await dateRangeResult.fold(
        (failure) {
          if (!isClosed) {
            emit(SupervisorError(message: failure.message));
          }
        },
        (dateRange) async {
          // Validate date range before creating filter
          DateTime startDate = dateRange.start;
          DateTime endDate = dateRange.end;

          // Ensure start is not after end
          if (startDate.isAfter(endDate)) {
            // Swap dates or use safe fallback
            final temp = startDate;
            startDate = endDate;
            endDate = temp;
          }

          // Ensure we have a reasonable date range
          if (startDate.isAfter(DateTime.now())) {
            startDate = DateTime.now().subtract(const Duration(days: 30));
          }
          if (endDate.isBefore(startDate)) {
            endDate = DateTime.now();
          }

          final defaultFilter = ChartFilterEntity(
            timePeriod: event.filter.timePeriod,
            entityType: event.filter.entityType,

            startDate: startDate,
            endDate: endDate,
          );

          final studentTimelineResult = await getTimelineUseCase(defaultFilter);

          if (isClosed) return;

          studentTimelineResult.fold(
            (failure) {
              if (!isClosed) {
                emit(SupervisorError(message: failure.message));
              }
            },
            (timelineData) {
              if (!isClosed) {
                final chartData = ChartFactory.createCompositeData(
                  timelineData: timelineData,
                  filter: defaultFilter,
                );

                emit(
                  currentState.copyWith(
                    timelineData: timelineData,
                    chartData: chartData,
                    filter: defaultFilter,
                    availableDateRange: dateRange,
                  ),
                );
              }
            },
          );
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(SupervisorError(message: 'حدث خطأ غير متوقع: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadCountsDeltaEntity(
    LoadCountsDeltaEntity event,
    Emitter<SupervisorState> emit,
  ) async {
    if (isClosed) return;

    emit(SupervisorLoading());

    try {
      final countResult = await getEntitiesCountsUseCase();

      if (isClosed) return;

      await countResult.fold(
        (failure) {
          if (!isClosed) {
            emit(SupervisorError(message: failure.message));
          }
        },
        (counts) async {
          if (isClosed) return;

          emit(SupervisorLoaded(countsDeltaEntity: counts));
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(SupervisorError(message: 'حدث خطأ غير متوقع: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateChartFilter(
    UpdateChartFilter event,
    Emitter<SupervisorState> emit,
  ) async {
    if (isClosed) return;

    final currentState = state;
    if (currentState is! SupervisorLoaded ||
        currentState.availableDateRange == null ||
        currentState.timelineData == null ||
        currentState.filter == null) {
      return;
    }

    emit(SupervisorLoading());

    try {
      final chartData = ChartFactory.createCompositeData(
        timelineData: currentState.timelineData!,
        filter: event.filter,
      );

      emit(currentState.copyWith(chartData: chartData, filter: event.filter));
    } catch (e) {
      if (!isClosed) {
        emit(SupervisorError(message: 'حدث خطأ غير متوقع'));
      }
    }
  }

  Future<void> _onApplicantsFetched(
    ApplicantsFetched event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(SupervisorLoading());

    final result = await getApplicantsUC(
      page: event.page,
      entityType: event.entityType,
    );

    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (paginatedResult) => emit(
        SupervisorLoaded(
          applicants: paginatedResult.applicants,
          applicantsCurrentPage: paginatedResult.pagination.currentPage,
          applicantsHasMorePages: paginatedResult.pagination.hasMorePages,
        ),
      ),
    );
  }

  Future<void> _onMoreApplicantsLoaded(
    MoreApplicantsLoaded event,
    Emitter<SupervisorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SupervisorLoaded ||
        !currentState.applicantsHasMorePages ||
        currentState.isLoadingMoreApplicants) {
      return;
    }

    emit(currentState.copyWith(isLoadingMoreApplicants: true));

    final nextPage = currentState.applicantsCurrentPage + 1;
    final result = await getApplicantsUC(
      page: nextPage,
      entityType: currentState.applicants.first.applicantType,
    );
    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMoreApplicants: false)),
      (paginatedResult) => emit(
        currentState.copyWith(
          isLoadingMoreApplicants: false,
          applicants: [
            ...currentState.applicants,
            ...paginatedResult.applicants,
          ],
          applicantsCurrentPage: paginatedResult.pagination.currentPage,
          applicantsHasMorePages: paginatedResult.pagination.hasMorePages,
        ),
      ),
    );
  }

  Future<void> _onApplicantProfileFetched(
    ApplicantProfileFetched event,
    Emitter<SupervisorState> emit,
  ) async {
    emit(SupervisorLoading());
    final result = await getApplicantProfileUC(event.applicantId);
    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (applicantProfile) => emit(
        SupervisorLoaded(applicantProfile: applicantProfile),
      ),
    );
  }

  Future<void> _onApproveApplicant(
    ApproveApplicant event,
    Emitter<SupervisorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SupervisorLoaded) return;

    emit(SupervisorLoading());
    final result = await approveApplicantUC(event.applicantId);
    result.fold(
      (failure) => emit(SupervisorError(message: failure.message)),
      (_) {
        final updatedApplicants = currentState.applicants
            .where((element) => element.id != event.applicantId)
            .toList();
        emit(
          currentState.copyWith(
            applicants: updatedApplicants,
            applicantProfile: null,
          ),
        );
      },
    );
  }

  Future<void> _onRejectApplicant(
    RejectApplicant event,
    Emitter<SupervisorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SupervisorLoaded) return;

    emit(currentState.copyWith(rejectStatus: ActionStatus.loading));

    final result =
        await rejectApplicantUC(event.applicantId, event.reason);
    result.fold(
      (failure) => emit(
        currentState.copyWith(
          rejectStatus: ActionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updatedApplicants = currentState.applicants
            .where((element) => element.id != event.applicantId)
            .toList();
        emit(
          currentState.copyWith(
            applicants: updatedApplicants,
            message: 'Applicant rejected and returned to the general pool.',
            rejectStatus: ActionStatus.success,
          ),
        );
      },
    );
  }
}
