import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';

class CustomTimePicker extends StatefulWidget {
  final void Function(TimeOfDay)? onTimeSelected;
  final TextEditingController controller;

  final IconData icon;
  final String label;

  const CustomTimePicker({
    super.key,
    this.onTimeSelected,
    required this.controller,

    required this.icon,
    required this.label,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  TimeOfDay? _selectedTime;

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              timeSelectorSeparatorTextStyle:
                  MaterialStateProperty.all<TextStyle>(
                    TextStyle(fontFamily: 'Cairo'),
                  ),

              cancelButtonStyle: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              confirmButtonStyle: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              // hourMinuteTextStyle: GoogleFonts.cairo(
              //   color: AppColors.lightCream,
              //   fontSize: 16,
              //   fontWeight: FontWeight.bold,
              // ),
              // dayPeriodTextStyle: GoogleFonts.cairo(
              //   color: AppColors.lightCream,
              //   fontSize: 16,
              //   fontWeight: FontWeight.bold,
              // ),
              backgroundColor: AppColors.mediumDark,
              hourMinuteTextColor: AppColors.lightCream,
              dialHandColor: AppColors.accent,
              dialBackgroundColor: AppColors.darkBackground,
              dialTextColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? AppColors.darkBackground
                    : AppColors.lightCream,
              ),
              entryModeIconColor: AppColors.accent,
              helpTextStyle: GoogleFonts.cairo(
                color: AppColors.lightCream,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              hourMinuteShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              hourMinuteColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? AppColors.accent
                    : AppColors.mediumDark38,
              ),
            ),
            textTheme: TextTheme(
              titleMedium: GoogleFonts.cairo(
                color: AppColors.lightCream,
                fontSize: 16,
              ),
              bodyMedium: GoogleFonts.cairo(
                color: AppColors.lightCream,
                fontSize: 14,
              ),
            ),
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.lightCream,
              surface: AppColors.mediumDark,
              onSurface: AppColors.lightCream,
              background: AppColors.darkBackground,
              onBackground: AppColors.lightCream,
              secondary: AppColors.lightCream,
              onSecondary: Colors.black,
              error: AppColors.error,
              onError: AppColors.lightCream,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
      if (widget.onTimeSelected != null) {
        widget.onTimeSelected!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // node ??= FocusNode(); // create one if none provided
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 14),
      child: TextFormField(
        controller: widget.controller,
        readOnly: true,
        keyboardType: TextInputType.none,
        style: GoogleFonts.cairo(color: AppColors.lightCream, fontSize: 12),
        cursorColor: AppColors.lightCream,
        decoration: InputDecoration(
          hintStyle: GoogleFonts.cairo(color: AppColors.lightCream70),
          labelText: widget.label,
          prefixStyle: GoogleFonts.cairo(
            color: AppColors.lightCream70,
            fontSize: 15,
          ),
          labelStyle: GoogleFonts.cairo(color: AppColors.lightCream70),
          prefixIcon: Icon(widget.icon, color: AppColors.accent70),
          filled: true,
          fillColor: AppColors.lightCream.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.mediumDark87,
              width: 2,
            ),
          ),
        ),
        onTap: () => _pickTime(),
      ),
    );
  }
}
