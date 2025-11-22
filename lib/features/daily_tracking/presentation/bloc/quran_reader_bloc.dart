// lib/features/quran_reader/presentation/bloc/quran_reader_bloc.dart

import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/surah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/usecases/get_page_data.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/usecases/get_surahs_list.dart';

import '../../../../core/utils/data_status.dart';
import '../../domain/usecases/get_mistakes_ayahs.dart';

part 'quran_reader_event.dart';
part 'quran_reader_state.dart';

class QuranReaderBloc extends Bloc<QuranReaderEvent, QuranReaderState> {
  final GetPageData _getPageData;
  final GetMistakesAyahs _getMistakesAyahs;
  final GetSurahsList _getSurahsList;

  /// PageController to manage the PageView in the UI.
  /// It's managed here to allow other parts of the app (like the bookmarks screen)
  /// to control the page navigation.

  QuranReaderBloc({
    required GetPageData getPageData,
    required GetMistakesAyahs getMistakesAyahs,
    required GetSurahsList getSurahsList,
    int initialPage = 0, // Allow setting an initial page
  }) : _getPageData = getPageData,
       _getMistakesAyahs = getMistakesAyahs,
       _getSurahsList = getSurahsList,
       super(const QuranReaderState()) {
    on<SurahsListRequested>(_onSurahsListRequested);
    on<PageDataRequested>(_onPageDataRequested);
    on<MistakesAyahsRequested>(_ongetMistakesAyahs);
  }

  Future<void> _onSurahsListRequested(
    SurahsListRequested event,
    Emitter<QuranReaderState> emit,
  ) async {
    emit(state.copyWith(surahsListStatus: DataStatus.loading));
    final result = await _getSurahsList(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          surahsListStatus: DataStatus.failure,
          surahsListFailure: failure,
        ),
      ),
      (surahs) => emit(
        state.copyWith(surahsListStatus: DataStatus.success, surahs: surahs),
      ),
    );
  }

  Future<void> _onPageDataRequested(
    PageDataRequested event,
    Emitter<QuranReaderState> emit,
  ) async {
    // ... (logic remains the same)
    if (state.pages.containsKey(event.pageNumber)) {
      emit(state.copyWith(currentPage: event.pageNumber));
      return;
    }
    emit(
      state.copyWith(
        pageDataStatus: DataStatus.loading,
        currentPage: event.pageNumber,
      ),
    );
    final result = await _getPageData(
      GetPageDataParams(pageNumber: event.pageNumber),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          pageDataStatus: DataStatus.failure,
          pageDataFailure: failure,
        ),
      ),
      (ayahs) {
        final updatedPages = Map<int, List<Ayah>>.from(state.pages);
        updatedPages[event.pageNumber] = ayahs;
        // pageController.jumpToPage(state.currentPage);
        emit(
          state.copyWith(
            pageDataStatus: DataStatus.success,
            pages: updatedPages,
          ),
        );
      },
    );
    log("--------------------------------------------");
    log("currentPage : ${state.currentPage}");
    log("surahs : ${state.surahs.length}");
    log("surahsListFailure : ${state.surahsListFailure}");
    log("pageDataStatus : ${state.pageDataStatus}");
    log("pages : ${state.pages.length}");
    log("pageDataFailure : ${state.pageDataFailure}");
  }

  Future<void> _ongetMistakesAyahs(
    MistakesAyahsRequested event,
    Emitter<QuranReaderState> emit,
  ) async {
    emit(state.copyWith(mistakesAyahsStatus: DataStatus.loading));

    final result = await _getMistakesAyahs(
      GetMistakesAyahsParams(ayahsNumbers: event.mistakes),
    );
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            mistakesAyahsStatus: DataStatus.failure,
            mistakeAyahsFailure: failure,
          ),
        );
      },
      (ayahs) {
        emit(
          state.copyWith(
            mistakesAyahsStatus: DataStatus.success,
            mistakesAyahs: ayahs,
          ),
        );
      },
    );
  }
}
