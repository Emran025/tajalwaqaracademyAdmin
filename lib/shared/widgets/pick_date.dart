import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';

class CustomDatePicker extends StatefulWidget {
  final void Function(DateTime)? onDateSelected;
  final TextEditingController controller;
  final IconData icon;
  final String label;

  const CustomDatePicker({
    super.key,
    this.onDateSelected,
    required this.controller,
    required this.icon,
    required this.label,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              rangePickerHeaderHelpStyle: GoogleFonts.cairo(
                color: AppColors.lightCream,
                fontSize: 14,
              ),
              rangePickerHeaderHeadlineStyle: GoogleFonts.cairo(
                color: AppColors.lightCream,
                fontSize: 14,
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

              backgroundColor: AppColors.mediumDark,
              // hourMinuteTextColor: AppColors.lightCream,
              // dialHandColor: AppColors.accent,
              // dialBackgroundColor: AppColors.darkBackground,
              // dialTextColor: MaterialStateColor.resolveWith(
              //   (states) => states.contains(MaterialState.selected)
              //       ? AppColors.darkBackground
              //       : AppColors.lightCream,
              // ),
              // entryModeIconColor: AppColors.accent,
              headerHeadlineStyle: GoogleFonts.cairo(
                color: AppColors.lightCream,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              headerHelpStyle: GoogleFonts.cairo(
                color: AppColors.lightCream,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              weekdayStyle: GoogleFonts.cairo(
                color: AppColors.lightCream,
                fontSize: 14,
              ),

              yearStyle: GoogleFonts.cairo(
                color: AppColors.lightCream,
                fontSize: 12,
              ),
              // dayStyle: GoogleFonts.cairo(
              //   color: AppColors.lightCream,
              //   fontSize: 12,
              // ),

              // hourMinuteShape: const RoundedRectangleBorder(
              //   borderRadius: BorderRadius.all(Radius.circular(8)),
              // ),
              // hourMinuteColor: MaterialStateColor.resolveWith(
              //   (states) => states.contains(MaterialState.selected)
              //       ? AppColors.accent
              //       : AppColors.mediumDark38,
              // ),
            ),
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent, // لون العناصر الأساسية
              onPrimary: AppColors.lightCream, // لون النص على الأزرار
              surface: AppColors.mediumDark, // خلفية الحوار
              onSurface: AppColors.lightCream, // لون النص العام
              background: AppColors.darkBackground, // خلفية الصفحة
              onBackground: AppColors.lightCream,
              secondary: AppColors.lightCream,
              onSecondary: Colors.black,
              error: AppColors.error,
              onError: AppColors.lightCream,
              brightness: Brightness.dark,
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
            dialogBackgroundColor: AppColors.mediumDark,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        if (widget.onDateSelected != null) {
          widget.onDateSelected!(picked);
        }
      });
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
        onTap: () => _pickDate(),
        // onTap(controller, label, keyboard) : null,

        // onSaved: ((val) {
        //   controller.text = val?.trim() ?? '';
        // }),
        // onChanged: ((val) {
        //   controller.text = val.trim();
        // }),
        // validator: (val) =>
        //     (val == null || val.isEmpty) ? " حقل $label مطلوب" : null,
      ),
    );
  }
}
