import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/chart_filter.dart';
import 'package:injectable/injectable.dart';

import '../repositories/tracking_repository.dart';

@lazySingleton
class GetErrorAnalysisChartData
    implements UseCase<List<BarChartDatas>, GetErrorAnalysisChartDataParams> {
  final TrackingRepository repository;

  GetErrorAnalysisChartData(this.repository);

  @override
  Future<Either<Failure, List<BarChartDatas>>> call(
      GetErrorAnalysisChartDataParams params) async {
    return await repository.getErrorAnalysisChartData(
      enrollmentId: params.enrollmentId,
      filter: params.filter,
    );
  }
}

class GetErrorAnalysisChartDataParams extends Equatable {
  final String enrollmentId;
  final ChartFilter filter;

  const GetErrorAnalysisChartDataParams({
    required this.enrollmentId,
    required this.filter,
  });

  @override
  List<Object?> get props => [enrollmentId, filter];
}
