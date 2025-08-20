import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/widgets/mistakes_list.dart';
import '../bloc/tracking_session_bloc.dart';


/// A dialog for reviewing, categorizing, and saving the progress of a single tracking task.
///
/// This stateful widget manages local UI state (text controllers, switches) while
/// listening to the [TrackingSessionBloc] for the core data. It orchestrates user
/// interactions, dispatching events to update the BLoC and ultimately save the report.
class MistakesDialog extends StatefulWidget {
  const MistakesDialog({super.key});

  @override
  State<MistakesDialog> createState() => _MistakesDialogState();
}

class _MistakesDialogState extends State<MistakesDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          "اخطاء: $taskName",
          style: Theme.of(context).textTheme.headlineSmall,
        );
      },
    );
  }



  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("اغلاق"),
          ),
        ),
      ],
    );
  }
}
