// lib/features/quran_reader/presentation/widgets/surah_juz_list_view.dart
import '../../../../core/utils/data_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/core/utils/app_strings.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/bloc/quran_reader_bloc.dart';
// import 'package:shimmer/shimmer.dart';
// We will need to create these list item widgets next.
// import 'package:tajalwaqaracademy/features/quran_reader/presentation/widgets/surah_list_item.dart';
// import 'package:tajalwaqaracademy/features/quran_reader/presentation/widgets/juz_list_item.dart';

/// A widget that displays a tabbed view for browsing Surahs and Juz'.
///
/// This is typically shown inside a modal bottom sheet when the user wants
/// to navigate the Quran index.
class SurahJuzListView extends StatelessWidget {
  final void Function(int) jumpToPage;

  const SurahJuzListView({super.key, required this.jumpToPage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2, // Two tabs: Surahs and Juz'
      child: Column(
        children: [
          // A small handle to indicate the sheet can be dragged.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // The TabBar for switching between lists.
          TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: colorScheme.primary,
            indicatorWeight: 3.0,
            tabs: const [
              Tab(text: AppStrings.surah),
              Tab(text: AppStrings.juz),
            ],
          ),

          // The content of the tabs.
          Expanded(
            child: TabBarView(children: [_buildSurahList(), _buildJuzList()]),
          ),
        ],
      ),
    );
  }

  /// Builds the list of Surahs.
  /// This will be populated using data from the QuranReaderBloc.
  Widget _buildSurahList() {
    // For now, this is a placeholder. We will replace this with a
    // BlocBuilder that listens to the QuranReaderBloc's surahs list.
    return BlocBuilder<QuranReaderBloc, QuranReaderState>(
      builder: (context, state) {
        if (state.surahsListStatus == DataStatus.loading) {
          return _buildLoadingIndicator(context);
        } else if (state.surahsListStatus == DataStatus.initial) {
          context.read<QuranReaderBloc>().add(SurahsListRequested());
        }
        if (state.surahsListStatus == DataStatus.success &&
            state.surahs.isNotEmpty) {
          return ListView.builder(
            itemCount: 114, // Placeholder count
            itemBuilder: (context, index) {
              // context.read<QuranReaderBloc>().add(SurahsListRequested());
              // Request the data for the very first page to be displayed.
              // This will be replaced by a dedicated SurahListItem widget
              // that receives a Surah entity.
              return ListTile(
                leading: Text('${index + 1}'),
                title: Text((state.surahs[index].name)), // Placeholder
                onTap: () {
                  // Logic to jump to the surah's page and close the sheet.
                  jumpToPage(state.surahs[index].firstPageStrtsAt - 1);

                  Navigator.of(context).pop();
                },
              );
            },
          );
        } else {
          return _buildErrorDisplay(context, state.pageDataFailure?.message);
        }
      },
    );
  }

  /// Builds the list of Juz'.
  Widget _buildJuzList() {
    // Placeholder implementation for the Juz list.
    return BlocBuilder<QuranReaderBloc, QuranReaderState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: 30, // 30 Juz'
          itemBuilder: (context, index) {
            // This will be replaced by a dedicated JuzListItem widget.
            return ListTile(
              leading: Text('${index + 1}'),
              title: Text(
                ' ${AppStrings.juzsList[index].juzName}',
              ), // Placeholder
              onTap: () {
                // Logic to jump to the juz's starting page and close the sheet.
                jumpToPage(AppStrings.juzsList[index].fromPage - 1);

                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  /// Builds a loading indicator using a shimmer effect for a professional look.
  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
  // /// Builds a loading indicator using a shimmer effect for a professional look.
  // Widget _buildLoadingIndicator(BuildContext context) {
  //   return Shimmer.fromColors(
  //     baseColor: Colors.grey.shade300,
  //     highlightColor: Colors.grey.shade100,
  //     child: Container(
  //       margin: const EdgeInsets.all(16.0),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12.0),
  //       ),
  //     ),
  //   );
  // }

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
              onPressed: () {},
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
