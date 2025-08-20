import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/core/utils/data_status.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';
import '../../domain/entities/mistake.dart';
import '../bloc/quran_reader_bloc.dart';
import '../bloc/tracking_session_bloc.dart';

// Import the newly separated widgets
import 'mistake_item_widget.dart';

/// A dialog for reviewing, categorizing, and saving the progress of a single tracking task.
///
/// This stateful widget manages local UI state (text controllers, switches) while
/// listening to the [TrackingSessionBloc] for the core data. It orchestrates user
/// interactions, dispatching events to update the BLoC and ultimately save the report.
class MistakesList extends StatefulWidget {
  const MistakesList({super.key});

  @override
  State<MistakesList> createState() => _MistakesListState();
}

class _MistakesListState extends State<MistakesList> {
  @override
  void initState() {
    super.initState();
    final currentDetail = context
        .read<TrackingSessionBloc>()
        .state
        .currentTaskDetail;
    // Dispatch the event to fetch Ayah texts when the dialog is initialized.
    final mistakes = currentDetail?.mistakes ?? [];
    if (mistakes.isNotEmpty) {
      final mistakeAyahIds = mistakes.map((e) => e.ayahIdQuran).toList();
      context.read<QuranReaderBloc>().add(
        MistakesAyahsRequested(mistakeAyahIds),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranReaderBloc, QuranReaderState>(
      builder: (context, quranState) {
        // We also need the session state.
        final sessionState = context.watch<TrackingSessionBloc>().state;
        final mistakes = sessionState.currentTaskDetail?.mistakes ?? [];
        final isLoading = quranState.mistakesAyahsStatus == DataStatus.loading;

        // Condition 1: If loading, show progress indicator.
        if (isLoading) {
          return const Center(
            heightFactor: 3,
            child: CircularProgressIndicator(),
          );
        }

        if (mistakes.isNotEmpty) {
          final mistakeAyahIds = mistakes.map((e) => e.ayahIdQuran).toList();
          context.read<QuranReaderBloc>().add(
            MistakesAyahsRequested(mistakeAyahIds),
          );
        }

        final mistakesAyahs = quranState.mistakesAyahs;
        // Condition 2: If data is ready and consistent, show the list.
        if (mistakes.length == mistakesAyahs.length) {
          return _buildMistakesList(context, mistakes, mistakesAyahs);
        }

        // Condition 3: Fallback for any other state (e.g., error, inconsistency).
        return const Center(
          heightFactor: 3,
          child: Text("خطأ في تحميل بيانات الآيات."),
        );
      },
    );
  }

  Widget _buildMistakesList(
    BuildContext context,
    List<Mistake> mistakes,
    List<Ayah> mistakesAyahs,
  ) {
    return LimitedBox(
      maxHeight: MediaQuery.of(context).size.height * 0.25,
      child: mistakes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("لا توجد أخطاء مسجلة لهذه المهمة."),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: mistakes.length,
              itemBuilder: (context, index) => MistakeItemWidget(
                mistake: mistakes[index],
                ayah: mistakesAyahs[index],
              ),
            ),
    );
  }
}
