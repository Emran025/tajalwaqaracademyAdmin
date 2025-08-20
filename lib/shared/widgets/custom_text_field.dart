import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool isPassword;
  final bool readOnly;
  final void Function(TextEditingController, String)? onTap;
  final String? Function(String?)? validator;
  final EdgeInsets padding;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.readOnly = false,
    this.validator,
    this.padding = const EdgeInsets.only(bottom: 12, left: 14),
  });

  @override
  Widget build(BuildContext context) {
    // node ??= FocusNode(); // create one if none provided
    return Padding(
      padding: padding,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: GoogleFonts.cairo(color: AppColors.lightCream, fontSize: 12),
        cursorColor: AppColors.lightCream,
        decoration: InputDecoration(
          hintStyle: GoogleFonts.cairo(color: AppColors.lightCream70),
          labelText: label,
          prefixStyle: GoogleFonts.cairo(
            color: AppColors.lightCream70,
            fontSize: 15,
          ),
          labelStyle: GoogleFonts.cairo(color: AppColors.lightCream70),
          prefixIcon: keyboardType == TextInputType.phone
              ? null
              : Icon(prefixIcon, color: AppColors.accent70),
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
        onTap: onTap != null ? () => onTap!(controller, label) : null,

        onSaved: ((val) {
          controller.text = val?.trim() ?? '';
        }),
        onChanged: ((val) {
          controller.text = val.trim();
        }),
        validator: (val) =>
            (val == null || val.isEmpty) ? " حقل $label مطلوب" : null,
      ),
    );
  }
}
