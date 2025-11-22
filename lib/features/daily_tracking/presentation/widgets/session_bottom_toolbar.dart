// lib/features/daily_tracking/presentation/widgets/session_bottom_toolbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran_reader_bloc.dart';
import '../bloc/tracking_session_bloc.dart';
import 'mistakes_dialog.dart';
import 'surah_juz_list_view.dart';
import 'task_report_dialog.dart';

/// A specialized bottom toolbar for the recitation session screen.
///
/// This toolbar provides actions relevant to the current tracking task,
/// such as saving progress, viewing the task report, and other session-related tools.
class SessionBottomToolbar extends StatelessWidget {
    final void Function(int) jumpToPage;

  const SessionBottomToolbar({super.key,  required this.jumpToPage});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(
        bottom: 16.0,
        top: 8.0,
        left: 8.0,
        right: 8.0,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // --- Button 1: Task Report (The most important one) ---
          _ToolbarButton(
            icon: Icons.assignment_turned_in_outlined,
            label: 'تقرير المهمة',
            onTap: () {
              // We need references to both BLoCs from the screen's context.
              final trackingBloc = BlocProvider.of<TrackingSessionBloc>(
                context,
              );
              final quranReaderBloc = BlocProvider.of<QuranReaderBloc>(context);
              showDialog(
                context: context,
                // It's important to wrap the Dialog with the same BlocProvider
                // to ensure it can access the TrackingSessionBloc instance.
                // Since the screen already has the provider, context.read will work,
                // but wrapping it here is safer if you move the dialog call.
                // However, the cleanest way is to ensure the calling context
                // is already under the correct BlocProvider.
                builder: (_) {
                  // We must provide the existing Bloc instance to the dialog's context tree.
                  // BlocProvider.value is the perfect tool for this.
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: trackingBloc),
                      BlocProvider.value(value: quranReaderBloc),
                    ],
                    child: const TaskReportDialog(),
                  );
                },
              );
            },
          ),

          // --- Button 1: Task Report (The most important one) ---

          // --- Button 2: Go to Page ---
          _ToolbarButton(
            icon: Icons.list_alt_rounded,
            label: 'الفهرس', // From AppStrings
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // Allows the sheet to be taller
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) {
                  // We use a fraction of the screen height for the sheet.
                  return BlocProvider.value(
                    value: BlocProvider.of<QuranReaderBloc>(context),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      // The SurahJuzListView will contain the TabBar and lists.
                      child:  SurahJuzListView(jumpToPage: jumpToPage,),
                    ),
                  );
                },
              );
              // Placeholder for 'Go to Page' functionality.
        
            },
          ),

          // --- Button 3: Audio Player (Future enhancement) ---
          _ToolbarButton(
            icon: Icons.report,
            label: 'عرض الأخطاء',
            onTap: () {
              // We need references to both BLoCs from the screen's context.
              final trackingBloc = BlocProvider.of<TrackingSessionBloc>(
                context,
              );
              final quranReaderBloc = BlocProvider.of<QuranReaderBloc>(context);
              showDialog(
                context: context,
                // It's important to wrap the Dialog with the same BlocProvider
                // to ensure it can access the TrackingSessionBloc instance.
                // Since the screen already has the provider, context.read will work,
                // but wrapping it here is safer if you move the dialog call.
                // However, the cleanest way is to ensure the calling context
                // is already under the correct BlocProvider.
                builder: (_) {
                  // We must provide the existing Bloc instance to the dialog's context tree.
                  // BlocProvider.value is the perfect tool for this.
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: trackingBloc),
                      BlocProvider.value(value: quranReaderBloc),
                    ],
                    child: const MistakesDialog(),
                  );
                },
              );
            },
          ),

          // --- Button 4: More Options (Could include theme, font size etc.) ---
          _ToolbarButton(
            icon: Icons.more_vert,
            label: 'المزيد',
            onTap: () {
              // Placeholder for more options.
              print('More Options Tapped');
            },
          ),
        ],
      ),
    );
  }
}

/// A private helper widget for a single button in the toolbar.
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
