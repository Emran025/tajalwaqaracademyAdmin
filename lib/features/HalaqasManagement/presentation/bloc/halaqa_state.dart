part of 'halaqa_bloc.dart';

enum HalaqaStatus { initial, loading, success, failure }

enum HalaqaDetailsStatus { initial, loading, success, failure }

enum HalaqaSubmissionStatus { initial, submitting, success, failure }

enum HalaqaUpsertStatus { initial, submitting, success, failure }

final class HalaqaState extends Equatable {
  final HalaqaStatus status;
  final List<HalaqaListItemEntity> halaqas;
  final bool hasMorePages;
  final int currentPage;
  final Failure? failure;
  final bool isLoadingMore;

  // --- Details State Properties (New) ---
  final HalaqaDetailsStatus detailsStatus;
  final HalaqaDetailEntity? selectedHalaqa;
  final Failure? detailsFailure;

  // --- Operation State (New) ---
  final HalaqaSubmissionStatus submissionStatus;
  final Failure? submissionFailure;
  // --- Operation State (New) ---
  final HalaqaUpsertStatus upsertStatus;
  final Failure? upsertFailure;

  const HalaqaState({
    this.status = HalaqaStatus.initial,
    this.halaqas = const [],
    this.hasMorePages = true,
    this.currentPage = 1,
    this.failure,
    this.isLoadingMore = false,

    // New
    this.detailsStatus = HalaqaDetailsStatus.initial,
    this.selectedHalaqa,
    this.detailsFailure,

    // New
    this.submissionStatus = HalaqaSubmissionStatus.initial,
    this.submissionFailure,
    // New
    this.upsertStatus = HalaqaUpsertStatus.initial,
    this.upsertFailure,
  });

  HalaqaState copyWith({
    HalaqaStatus? status,
    List<HalaqaListItemEntity>? halaqas,
    bool? hasMorePages,
    int? currentPage,
    Failure? failure,
    bool? isLoadingMore,

    // New
    HalaqaDetailsStatus? detailsStatus,
    HalaqaDetailEntity? selectedHalaqa,
    Failure? detailsFailure,
    // Flags to clear specific errors
    bool clearListFailure = false,
    bool clearDetailsFailure = false,

    // New
    HalaqaSubmissionStatus? submissionStatus,
    Failure? submissionFailure,
    bool clearSubmissionFailure = false,
    // New
    HalaqaUpsertStatus? upsertStatus,
    Failure? upsertFailure,
    bool clearUpsertFailure = false,
  }) {
    return HalaqaState(
      status: status ?? this.status,
      halaqas: halaqas ?? this.halaqas,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      currentPage: currentPage ?? this.currentPage,
      failure: clearListFailure ? null : failure ?? this.failure,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      // New
      detailsStatus: detailsStatus ?? this.detailsStatus,
      selectedHalaqa: selectedHalaqa ?? this.selectedHalaqa,
      detailsFailure: clearDetailsFailure
          ? null
          : detailsFailure ?? this.detailsFailure,

      // New
      submissionStatus: submissionStatus ?? this.submissionStatus,
      submissionFailure: clearSubmissionFailure
          ? null
          : submissionFailure ?? this.submissionFailure,
      // New
      upsertStatus: upsertStatus ?? this.upsertStatus,
      upsertFailure: clearUpsertFailure
          ? null
          : upsertFailure ?? this.upsertFailure,
    );
  }

  @override
  List<Object?> get props => [
    status, halaqas, hasMorePages, currentPage, failure, isLoadingMore, // New
    detailsStatus,
    selectedHalaqa,
    detailsFailure,
    submissionStatus,
    submissionFailure,
    upsertStatus,
    upsertFailure,
  ];
}
