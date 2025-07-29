import 'dart:ui';

import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/constants/countries_names.dart';
import 'package:tajalwaqaracademy/core/models/countery_model.dart';

import 'package:tajalwaqaracademy/shared/widgets/country_picker_dialog.dart';

class PhoneZoneForm extends StatefulWidget {
  final TextEditingController zoneController;
  final TextEditingController phoneController;
  final CountryModel initialCountry;
  final String label;
  final VoidCallback? onCountryChanged;

  const PhoneZoneForm({
    super.key,
    required this.zoneController,
    required this.phoneController,
    required this.initialCountry,
    required this.label,
    this.onCountryChanged,
  });

  @override
  State<PhoneZoneForm> createState() => _PhoneZoneFormState();
}

class _PhoneZoneFormState extends State<PhoneZoneForm> {
  late CountryModel _selectedCountry;
  final _zoneFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry;
    widget.zoneController.text = _selectedCountry.countryCallingCode;
  }

  @override
  void dispose() {
    _zoneFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _onZoneChanged(String value) {
    final match = countries.firstWhere(
      (c) => c.countryCallingCode == value,
      orElse: () => _selectedCountry,
    );
    setState(() => _selectedCountry = match);
    widget.onCountryChanged?.call();
    if (value.isNotEmpty) {
      _phoneFocusNode.requestFocus();
    }
  }

  void _onBackspace(
    RawKeyEvent event,
    TextEditingController controller,
    FocusNode currentNode,
    FocusNode previousNode,
  ) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        controller.text.isEmpty) {
      previousNode.requestFocus();
    }
  }

  void _openCountryDialog() {
    showDialog(
      context: context,
      builder: (_) => CountryPickerDialog(
        initialCountry: _selectedCountry,
        onCountrySelected: (country) {
          setState(() => _selectedCountry = country);
          widget.zoneController.text = country.countryCallingCode;
          widget.onCountryChanged?.call();
        },
        isCollingCode: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 12, left: 14),
      decoration: BoxDecoration(
        color: AppColors.lightCream.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Country code selector
          SizedBox(
            width: MediaQuery.of(context).size.width / 4,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _openCountryDialog,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Flag.fromString(
                      _selectedCountry.status,
                      height: 18,
                      width: 24,
                    ),
                  ),
                ),
                Text(
                  "+",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightCream,
                  ),
                ),
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: _zoneFocusNode,
                    onKey: (e) => _onBackspace(
                      e,
                      widget.zoneController,
                      _zoneFocusNode,
                      _phoneFocusNode,
                    ),
                    child: TextFormField(
                      controller: widget.zoneController,
                      focusNode: _zoneFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration.collapsed(
                        hintText: _selectedCountry.countryCallingCode,
                      ),
                      onChanged: _onZoneChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Text(
            "|",
            style: GoogleFonts.cairo(
              fontSize: 25,
              color: AppColors.lightCream26,
            ),
          ),

          // Phone number field
          Expanded(
            child: RawKeyboardListener(
              focusNode: _phoneFocusNode,
              onKey: (e) => _onBackspace(
                e,
                widget.phoneController,
                _phoneFocusNode,
                _zoneFocusNode,
              ),
              child: TextFormField(
                controller: widget.phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                style: GoogleFonts.cairo(color: AppColors.lightCream),
                cursorColor: AppColors.lightCream,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  hintStyle: GoogleFonts.cairo(color: AppColors.lightCream70),
                  labelText: widget.label,
                  labelStyle: GoogleFonts.cairo(color: AppColors.lightCream70),
                  filled: false,
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
                validator: (val) => (val == null || val.isEmpty)
                    ? "حقل ${widget.label} مطلوب"
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
