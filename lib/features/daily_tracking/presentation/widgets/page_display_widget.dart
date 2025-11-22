// lib/features/quran_reader/presentation/widgets/page_display_widget.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tajalwaqaracademy/core/utils/app_assets.dart';
import 'package:tajalwaqaracademy/core/utils/app_strings.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/widgets/ayah_text_spans.dart';
import '../../domain/entities/mistake.dart';
import '../bloc/quran_reader_bloc.dart';
// import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/data_status.dart';

import '../bloc/tracking_session_bloc.dart';
import 'top_title_page_header_widget.dart'; // Add shimmer package to pubspec.yaml

/// A widget responsible for displaying the content of a single Quran page.
///
/// It listens to the [QuranReaderBloc] state to get the ayahs for the given
/// [pageNumber]. It handles loading and error states gracefully.

class PageDisplayWidget extends StatefulWidget {
  final int pageNumber;

  const PageDisplayWidget({super.key, required this.pageNumber });

  @override
  State<PageDisplayWidget> createState() => _PageDisplayWidgetState();
}

class _PageDisplayWidgetState extends State<PageDisplayWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Wrap with BlocBuilder for TrackingSessionBloc to get mistake data.
    return BlocBuilder<TrackingSessionBloc, TrackingSessionState>(
      buildWhen: (prev, curr) =>
          prev.currentTaskDetail?.mistakes !=
              curr.currentTaskDetail?.mistakes ||
          prev.currentTaskDetail?.gap != curr.currentTaskDetail?.gap,
      builder: (context, sessionState) {
        // Get all mistakes for the current active task.
        final allMistakesForCurrentTask =
            sessionState.currentTaskDetail?.mistakes ?? [];

        // 2. The original BlocSelector for QuranReaderBloc remains inside.
        return BlocSelector<QuranReaderBloc, QuranReaderState, List<Ayah>?>(
          selector: (quranState) => quranState.pages[widget.pageNumber],
          builder: (context, ayahs) {
            // ... the rest of your original `builder` code goes here, but now
            // you have access to `allMistakesForCurrentTask`.

            // Case 1: Page data is loaded and available.
            if (ayahs != null && ayahs.isNotEmpty) {
              // ... Your existing code for Stack, Align, LayoutBuilder etc. ...
              // IMPORTANT: We will modify the call to _buildPageContent
              return Center(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: TopTitlePageHeaderWidget(
                        pageNumber: widget.pageNumber,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          var horizontal = 15.0;
                          if (width <= 400) {
                            horizontal = 12.5;
                          }
                          if (width > 400) {
                            horizontal = 10;
                          }
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontal,
                            ),
                            child: _buildPageContent(
                              context,
                              ayahs,
                              allMistakesForCurrentTask,
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: SvgPicture.asset(
                              SvgAssets().soraNum,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, 1),
                            child: Text(
                              (widget.pageNumber).toString(),
                              style: TextStyle(
                                fontSize:
                                    (MediaQuery.of(context).orientation) ==
                                        Orientation.portrait
                                    ? 12.0
                                    : 14.0,
                                fontWeight: FontWeight.bold,
                                height: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            // Case 2: Page data is not yet loaded, check the status.
            return BlocBuilder<QuranReaderBloc, QuranReaderState>(
              builder: (context, state) {
                // Check if the currently loading page is this one.
                if (state.pageDataStatus == DataStatus.loading &&
                    state.currentPage == widget.pageNumber) {
                  return _buildLoadingIndicator(context);
                }
                // Check if there was a failure loading this page.
                if (state.pageDataStatus == DataStatus.failure &&
                    state.currentPage == widget.pageNumber) {
                  return _buildErrorDisplay(
                    context,
                    state.pageDataFailure?.message,
                  );
                }
                // Default case: Page not loaded, not loading, and no error.
                // This can happen briefly before the request is made.
                // A loading indicator is a safe fallback.
                return _buildLoadingIndicator(context);
              },
            );
          },
        );
      },
    );
  }

  //===========================================================================
  // REFACTORED CODE BLOCK - START
  //===========================================================================

  /// Groups a flat list of ayahs into a list of lists, where each inner list
  /// represents all ayahs belonging to a single surah on the page.
  ///
  /// **Important:** This function critically assumes that the input `ayahs` list
  /// is already sorted by `surahNumber` and then by `numberInSurah`.
  List<List<Ayah>> _groupAyahsBySurah(List<Ayah> ayahs) {
    if (ayahs.isEmpty) {
      return [];
    }

    final List<List<Ayah>> groupedSurahs = [];
    List<Ayah> currentSurahGroup = [ayahs.first];

    for (int i = 1; i < ayahs.length; i++) {
      final Ayah currentAyah = ayahs[i];
      final Ayah previousAyah = ayahs[i - 1];

      if (currentAyah.surahNumber == previousAyah.surahNumber) {
        currentSurahGroup.add(currentAyah);
      } else {
        groupedSurahs.add(currentSurahGroup);
        currentSurahGroup = [currentAyah];
      }
    }
    groupedSurahs.add(currentSurahGroup);
    return groupedSurahs;
  }
  // lib/features/quran_reader/presentation/widgets/page_display_widget.dart

  /// Builds the main page content as a single, vertically centered block.
  /// This approach uses a Column, which is the correct widget for non-scrolling content
  /// that needs to be centered as a whole.

  // Add the new parameter: List<Mistake> allMistakes
  Widget _buildPageContent(
    BuildContext context,
    List<Ayah> ayahs,
    List<Mistake> allMistakes,
  ) {
    final List<List<Ayah>> groupedSurahs = _groupAyahsBySurah(ayahs);
    if (groupedSurahs.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final ayahsInSurah in groupedSurahs) ...[
          if (ayahsInSurah.first.numberInSurah == 1)
            _buildSurahHeaderWidget(context, ayahsInSurah.first.surahNumber),

          AyahTextSpans(ayahsInSurah: ayahsInSurah, allMistakes: allMistakes),
        ],
      ],
    );
  }

  /// Builds the decorative header widget for a new surah.
  Widget _buildSurahHeaderWidget(BuildContext context, int surahNumber) {
    // TODO: Fetch the actual surah name from your BLoC state or a repository
    // using the surahNumber.

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  AppAssets.svg.surahAyahBanner1,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 30,
                ),
                SizedBox(
                  // height: 27.h,
                  width: 120,
                  child: SvgPicture.asset(
                    AppAssets.svg.surahName(surahNumber),
                    height: 22,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Add Basmalah for all surahs except Al-Fatiha (1) and At-Tawbah (9)
          if (surahNumber != 1 && surahNumber != 9)
            SvgPicture.asset(
              AppAssets.svg.besmAllah,
              width: 150.0,
              // height: 100,
              color: Theme.of(context).colorScheme.secondary,
              // color: const Color(0xffd0d0d0),
            ),
        ],
      ),
    );
  }

  /// Builds a loading indicator using a shimmer effect for a professional look.
  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }

  /// Builds the UI to display when an error occurs.
  Widget _buildErrorDisplay(BuildContext context, String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? AppStrings.defaultErrorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Retry fetching the data for this page.
                context.read<QuranReaderBloc>().add(
                  PageDataRequested(widget.pageNumber),
                );
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  //===========================================================================
  // REFACTORED CODE BLOCK - END
  //===========================================================================
}
