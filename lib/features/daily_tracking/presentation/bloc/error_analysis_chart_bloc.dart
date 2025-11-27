import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/usecases/get_error_analysis_chart_data.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/chart_filter.dart';

part 'error_analysis_chart_event.dart';
part 'error_analysis_chart_state.dart';

class ErrorAnalysisChartBloc
    extends Bloc<ErrorAnalysisChartEvent, ErrorAnalysisChartState> {
  final GetErrorAnalysisChartData getErrorAnalysisChartData;

  ErrorAnalysisChartBloc({required this.getErrorAnalysisChartData})
      : super(ErrorAnalysisChartInitial()) {
    on<LoadErrorAnalysisChartData>(_onLoadErrorAnalysisChartData);
    on<UpdateErrorAnalysisChartFilter>(_onUpdateErrorAnalysisChartFilter);
  }

  Future<void> _onLoadErrorAnalysisChartData(
    LoadErrorAnalysisChartData event,
    Emitter<ErrorAnalysisChartState> emit,
  ) async {
    emit(ErrorAnalysisChartLoading());
    final result = await getErrorAnalysisChartData(
      GetErrorAnalysisChartDataParams(
        enrollmentId: event.enrollmentId,
        filter: event.filter,
      ),
    );
    result.fold(
      (failure) => emit(ErrorAnalysisChartError(message: failure.toString())),
      (chartData) => emit(ErrorAnalysisChartLoaded(
        chartData: chartData,
        filter: event.filter,
        enrollmentId: event.enrollmentId,
      )),
    );
  }

  Future<void> _onUpdateErrorAnalysisChartFilter(
    UpdateErrorAnalysisChartFilter event,
    Emitter<ErrorAnalysisChartState> emit,
  ) async {
    if (state is ErrorAnalysisChartLoaded) {
      final currentState = state as ErrorAnalysisChartLoaded;
      add(LoadErrorAnalysisChartData(
        enrollmentId: currentState.enrollmentId,
        filter: event.filter,
      ));
    }
  }
}
