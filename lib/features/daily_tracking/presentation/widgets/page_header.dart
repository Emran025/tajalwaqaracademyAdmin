// lib/features/quran_reader/presentation/widgets/page_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/core/utils/app_strings.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/bloc/quran_reader_bloc.dart';

/// A widget that displays header information for the current Quran page.
///
/// It shows the current Surah name and Juz' number. It listens to the
/// [QuranReaderBloc] to update itself as the user navigates through pages.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

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
        // Find the first ayah of the current page to determine surah and juz.
        final List<Ayah>? ayahsOnPage = state.pages[state.currentPage];

        String surahName = '';
        String juzNumber = '';

        if (ayahsOnPage != null &&
            ayahsOnPage.isNotEmpty &&
            state.surahs.isNotEmpty) {
          final firstAyah = ayahsOnPage.first;
          juzNumber = firstAyah.juz.toString();

          // Find the surah name from the surahs list.
          try {
            surahName = state.surahs
                .firstWhere((s) => s.number == firstAyah.surahNumber)
                .name;
          } catch (e) {
            // Fallback in case the surah is not found (should not happen in a valid state).
            surahName = AppStrings.surah;
          }
        } else {
          // While data is loading, show placeholders.
          surahName = '...';
          juzNumber = '...';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.background.withOpacity(0.9),
            // You can add a subtle border or shadow here if desired.
            // border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Display Juz Number
              _buildHeaderText(context, text: '${AppStrings.juz} $juzNumber'),

              // Display Surah Name
              _buildHeaderText(context, text: surahName, isSurahName: true),
            ],
          ),
        );
      },
    );
  }

  /// A helper widget to build the styled text for the header.
  Widget _buildHeaderText(
    BuildContext context, {
    required String text,
    bool isSurahName = false,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: isSurahName
            ? 'Uthmanic'
            : 'Cairo', // Use a distinct font for Surah names
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
      ),
    );
  }
}
