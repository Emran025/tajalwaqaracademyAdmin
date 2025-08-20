part of 'quran_reader_bloc.dart';

class QuranReaderState extends Equatable {
  // Status for loading the list of surahs
  final DataStatus surahsListStatus;
  final List<Surah> surahs;
  final Failure? surahsListFailure;

  // Status for loading the data of the currently visible page
  final DataStatus pageDataStatus;
  final Map<int, List<Ayah>> pages; // Cache pages that have been loaded
  final Failure? pageDataFailure;

  final List<Ayah> mistakesAyahs;
  final DataStatus mistakesAyahsStatus;
  final Failure? mistakeAyahsFailure;

  // Current page displayed to the user
  final int currentPage;

  const QuranReaderState({
    this.surahsListStatus = DataStatus.initial,
    this.surahs = const [],
    this.surahsListFailure,
    this.pageDataStatus = DataStatus.initial,
    this.pages = const {},
    this.pageDataFailure,
    this.mistakesAyahs = const [],
    this.mistakesAyahsStatus = DataStatus.initial,
    this.mistakeAyahsFailure,
    this.currentPage = 1,
  });

  QuranReaderState copyWith({
    DataStatus? surahsListStatus,
    List<Surah>? surahs,
    Failure? surahsListFailure,
    DataStatus? pageDataStatus,
    Map<int, List<Ayah>>? pages,
    Failure? pageDataFailure,
    List<Ayah>? mistakesAyahs,
    DataStatus? mistakesAyahsStatus,
    Failure? mistakeAyahsFailure,
    int? currentPage,
  }) {
    return QuranReaderState(
      surahsListStatus: surahsListStatus ?? this.surahsListStatus,
      surahs: surahs ?? this.surahs,
      surahsListFailure: surahsListFailure, // Allow setting failure to null
      pageDataStatus: pageDataStatus ?? this.pageDataStatus,
      pages: pages ?? this.pages,
      pageDataFailure: pageDataFailure, // Allow setting failure to null
      mistakesAyahs:
          mistakesAyahs ?? this.mistakesAyahs, // Allow setting failure to null
      mistakeAyahsFailure: mistakeAyahsFailure, // Allow setting failure to null
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    surahsListStatus,
    surahs,
    surahsListFailure,
    pageDataStatus,
    pages,
    pageDataFailure,
    mistakesAyahs,
    mistakesAyahsStatus,
    mistakeAyahsFailure,
    currentPage,
  ];
}
