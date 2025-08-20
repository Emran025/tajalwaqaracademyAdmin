// lib/features/quran_reader/presentation/widgets/page_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/core/utils/app_strings.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/bloc/quran_reader_bloc.dart';

/// A widget that displays header information for the current Quran page.

/// It shows the current Surah name and Juz' number. It listens to the
/// [QuranReaderBloc] to update itself as the user navigates through pages.
class TopTitlePageHeaderWidget extends StatelessWidget {
  final int pageNumber;

  const TopTitlePageHeaderWidget({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // BlocBuilder listens to the state and rebuilds the header when the
    // current page's data changes.
    return BlocBuilder<QuranReaderBloc, QuranReaderState>(
      // buildWhen ensures we only rebuild if the page data or surah list changes,
      // which is more efficient.
      buildWhen: (previous, current) =>
          previous.currentPage != current.currentPage ||
          previous.pages != current.pages ||
          previous.surahs.isEmpty != current.surahs.isEmpty,
      builder: (context, state) {
        final List<Ayah>? ayahsOnPage = state.pages[pageNumber];
        String surahName = '';
        int juzNumber = 0;
        if (ayahsOnPage != null &&
            ayahsOnPage.isNotEmpty &&
            state.surahs.isNotEmpty) {
          final firstAyah = ayahsOnPage.first;
          juzNumber = firstAyah.juz - 1;
          try {
            surahName = state.surahs
                .firstWhere((s) => s.number == firstAyah.surahNumber)
                .name;
          } catch (e) {
            surahName = AppStrings.surah;
          }
        } else {
          surahName = '...';
          juzNumber = 0;
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.background.withOpacity(0.9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderText(
                context,
                text: AppStrings.juzsList[juzNumber].juzName,
              ),
              _buildHeaderText(context, text: surahName),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderText(BuildContext context, {required String text}) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Uthmanic',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
      ),
    );
  }
}
