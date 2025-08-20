import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tracking_session_bloc.dart'; // Import the BLoC

/// A dialog for the teacher to enter final remarks for the entire session.
///
/// This includes notes on student behavior and a general summary of the
/// recitation session. It uses [TextEditingController]s to manage the
/// input and dispatches an event to the [TrackingSessionBloc] on submission.
class FinalReportDialog extends StatefulWidget {
  const FinalReportDialog({super.key});

  @override
  State<FinalReportDialog> createState() => _FinalReportDialogState();
}

class _FinalReportDialogState extends State<FinalReportDialog> {
  // Controllers to manage the text fields' state.
  late final TextEditingController _behavioralNotesController;
  late final TextEditingController _generalNotesController;

  @override
  void initState() {
    super.initState();
    _behavioralNotesController = TextEditingController();
    _generalNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _behavioralNotesController.dispose();
    _generalNotesController.dispose();
    super.dispose();
  }

  // A method to handle the submission of the report.
  void _submitReport() {
    // Read the text from the controllers.
    final behavioralNotes = _behavioralNotesController.text;
    final generalNotes = _generalNotesController.text;

    // Dispatch the event to the BLoC with the collected data.
    context.read<TrackingSessionBloc>().add(
      FinalSessionReportSaved(
        behavioralNotes: behavioralNotes,
        generalNotes: generalNotes,
      ),
    );

    // Close the dialog after submission.
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
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.background.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.5),
              width: 0.7,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "التقرير النهائي للجلسة",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  // Associate the controller with the TextField.
                  controller: _behavioralNotesController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "ملاحظات السلوك...",
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  // Associate the controller with the TextField.
                  controller: _generalNotesController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "ملاحظة عامة على التسميع...",
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("إلغاء"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        // The button now calls the _submitReport method.
                        onPressed: _submitReport,
                        child: const Text("رفع التقرير"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}