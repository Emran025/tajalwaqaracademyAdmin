import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/themes/app_theme.dart';
import '../../../../../core/models/active_status.dart';

class StatusTag extends StatelessWidget {
  final ActiveStatus? status;
  final String? lable;
  final double? fontSize;
  final double? radius;
  const StatusTag({
    super.key,
    this.status = ActiveStatus.inactive,
    this.lable = "",
    this.fontSize = 14,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (status == ActiveStatus.active)
      bg = AppColors.success;
    else if (status == ActiveStatus.stopped)
      bg = AppColors.error;
    else
      bg = Colors.orange.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius!),
      ),
      child: Text(
        lable == '' ? status!.labelAr : lable!,
        style: GoogleFonts.cairo(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: bg.computeLuminance() > .5
              ? Colors.black87
              : AppColors.lightCream,
        ),
      ),
    );
  }
}
