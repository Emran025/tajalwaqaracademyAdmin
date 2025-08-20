import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/widgets/mistakes_list.dart';

import '../bloc/tracking_session_bloc.dart';

// Import the newly separated widgets
import 'quality_rating_bar_widget.dart';

/// A dialog for reviewing, categorizing, and saving the progress of a single tracking task.
///
/// This stateful widget manages local UI state (text controllers, switches) while
/// listening to the [TrackingSessionBloc] for the core data. It orchestrates user
/// interactions, dispatching events to update the BLoC and ultimately save the report.
class TaskReportDialog extends StatefulWidget {
  const TaskReportDialog({super.key});

  @override
  State<TaskReportDialog> createState() => _TaskReportDialogState();
}

class _TaskReportDialogState extends State<TaskReportDialog> {
  late final TextEditingController _notesController;
  bool _isFinalizingTask = false;

  @override
  void initState() {
    super.initState();
    final currentDetail = context
        .read<TrackingSessionBloc>()
        .state
        .currentTaskDetail;
    _notesController = TextEditingController(
      text: currentDetail?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveReport() {
    // Read the final state from the BLoC for rating, as it's the source of truth.
    final currentRating =
        context.read<TrackingSessionBloc>().state.currentTaskDetail?.score ?? 0;

    context.read<TrackingSessionBloc>().add(
      TaskReportSaved(
        notes: _notesController.text,
        rating: currentRating,
        isFinalizingTask: _isFinalizingTask,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                // We use a single BlocBuilder that watches both BLoCs and decides what to show.
                MistakesList(),

                const Divider(height: 32, thickness: 0.5),
                _buildSectionHeader(context, "تقييم الجودة"),
                const QualityRatingBar(),
                const SizedBox(height: 10),
                _buildSectionHeader(context, "ملاحظات المهمة"),
                TextField(
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "أضف ملاحظة على المهمة (اختياري)",
                    filled: true,
                    fillColor: theme.colorScheme.surface.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildFinalizeSwitch(theme),
                const SizedBox(height: 10),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Use BlocSelector to get the task name and prevent unnecessary rebuilds.
    return BlocSelector<TrackingSessionBloc, TrackingSessionState, String>(
      selector: (state) => state.currentTaskType.labelAr,
      builder: (context, taskName) {
        return Text(
          "تقرير مهمة: $taskName",
          style: Theme.of(context).textTheme.headlineSmall,
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildFinalizeSwitch(ThemeData theme) {
    return SwitchListTile.adaptive(
      title: const Text("إنهاء المهمة (تضمين في التقرير)"),
      value: _isFinalizingTask,
      onChanged: (newValue) => setState(() => _isFinalizingTask = newValue),
      activeColor: theme.colorScheme.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("إلغاء"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveReport,
            child: Text(_isFinalizingTask ? "حفظ وإنهاء" : "حفظ المسودة"),
          ),
        ),
      ],
    );
  }
}
