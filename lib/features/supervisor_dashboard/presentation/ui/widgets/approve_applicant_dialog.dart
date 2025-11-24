import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApproveApplicantDialog extends StatefulWidget {
  final int applicantId;
  final VoidCallback onConfirm;

  const ApproveApplicantDialog({
    super.key,
    required this.applicantId,
    required this.onConfirm,
  });

  @override
  State<ApproveApplicantDialog> createState() => _ApproveApplicantDialogState();
}

class _ApproveApplicantDialogState extends State<ApproveApplicantDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تأكيد القبول',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('هل أنت متأكد من قبول هذا المقدم؟'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isLoading = true;
                            });
                            widget.onConfirm();
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('قبول'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
