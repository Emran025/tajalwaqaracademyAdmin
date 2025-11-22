// bloc/student_timeline_bloc.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/composite_performance_data.dart';
import '../../domain/entities/chart_filter_entity.dart';
import '../../domain/entities/counts_delta_entity.dart';
import '../../domain/entities/timeline_entity.dart';
import '../../domain/factories/chart_factory.dart';
import '../../domain/usecases/get_date_range_use_case.dart';
import '../../domain/usecases/get_entities_counts_use_case.dart';
import '../../domain/usecases/get_timeline_use_case.dart';

part 'supervisor_timeline_event.dart';
part 'supervisor_timeline_state.dart';

class SupervisorTimelineBloc
    extends Bloc<SupervisorTimelineEvent, SupervisorTimelineState> {
  final GetEntitiesCountsUseCase getEntitiesCountsUseCase;
  final GetTimelineUseCase getTimelineUseCase;
  final GetDateRangeUseCase getDateRangeUseCase;

  SupervisorTimelineBloc({
    required this.getEntitiesCountsUseCase,
    required this.getTimelineUseCase,
    required this.getDateRangeUseCase,
  }) : super(SupervisorTimelineInitial()) {
    on<LoadCountsDeltaEntity>(_onLoadCountsDeltaEntity);
    on<LoadTimeline>(_onLoadTimeline);
    on<UpdateChartFilter>(_onUpdateChartFilter);
  }

  Future<void> _onLoadTimeline(
    LoadTimeline event,
    Emitter<SupervisorTimelineState> emit,
  ) async {
    if (isClosed) return;

    final currentState = state;
    if (currentState is! SupervisorTimelineLoaded) return;

    emit(SupervisorTimelineLoading());

    try {
      final dateRangeResult = await getDateRangeUseCase(
        event.filter.entityType,
      );

      if (isClosed) return;

      await dateRangeResult.fold(
        (failure) {
          if (!isClosed) {
            emit(SupervisorTimelineError(failure.message));
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
                emit(SupervisorTimelineError(failure.message));
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
        emit(SupervisorTimelineError('حدث خطأ غير متوقع: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadCountsDeltaEntity(
    LoadCountsDeltaEntity event,
    Emitter<SupervisorTimelineState> emit,
  ) async {
    if (isClosed) return;

    emit(SupervisorTimelineLoading());

    try {
      final countResult = await getEntitiesCountsUseCase();

      if (isClosed) return;

      await countResult.fold(
        (failure) {
          if (!isClosed) {
            emit(SupervisorTimelineError(failure.message));
          }
        },
        (counts) async {
          if (isClosed) return;

          emit(SupervisorTimelineLoaded(countsDeltaEntity: counts));
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(SupervisorTimelineError('حدث خطأ غير متوقع: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateChartFilter(
    UpdateChartFilter event,
    Emitter<SupervisorTimelineState> emit,
  ) async {
    if (isClosed) return;

    final currentState = state;
    if (currentState is! SupervisorTimelineLoaded ||
        currentState.availableDateRange == null ||
        currentState.timelineData == null ||
        currentState.filter == null) {
      return;
    }

    emit(SupervisorTimelineLoading());

    try {
      final chartData = ChartFactory.createCompositeData(
        timelineData: currentState.timelineData!,
        filter: event.filter,
      );

      emit(currentState.copyWith(chartData: chartData, filter: event.filter));
    } catch (e) {
      if (!isClosed) {
        emit(SupervisorTimelineError('حدث خطأ غير متوقع'));
      }
    }
  }
}
