import 'dart:async';
import 'dart:ui';

import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/constants/countries_names.dart';
import 'package:tajalwaqaracademy/core/models/countery_model.dart';

class CountryPickerDialog extends StatefulWidget {
  final CountryModel initialCountry;
  final ValueChanged<CountryModel> onCountrySelected;
  final bool isCollingCode;

  const CountryPickerDialog({
    super.key,

    required this.initialCountry,
    required this.onCountrySelected,
    required this.isCollingCode,
  });

  @override
  State<CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  late List<CountryModel> _filtered;
  late FocusNode _focusNode;
  late CountryModel _tempSelected;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filtered = countries;
    _tempSelected = widget.initialCountry;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _filtered = countries
            .where((c) => c.arabicName.contains(query))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: AppColors.lightCream.withOpacity(0.1),
            insetPadding: const EdgeInsets.all(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxHeight: 500),
                decoration: BoxDecoration(
                  color: AppColors.accent12,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent70, width: 0.7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'قم بتحديد الدولة...',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightCream,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      style: GoogleFonts.cairo(color: AppColors.lightCream),
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "ابحث عن الدولة",
                        hintStyle: GoogleFonts.cairo(
                          color: AppColors.lightCream70,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.lightCream,
                        ),
                        filled: true,
                        fillColor: AppColors.lightCream.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: AppColors.accent),
                          itemBuilder: (_, i) {
                            final country = _filtered[i];
                            return RadioListTile<CountryModel>(
                              value: country,
                              groupValue: _tempSelected,
                              title: Text(
                                country.arabicName,
                                style: GoogleFonts.cairo(
                                  color: AppColors.lightCream,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              secondary: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  widget.isCollingCode
                                      ? Text(
                                          "+${country.countryCallingCode}",
                                          textDirection: TextDirection.ltr,
                                          style: GoogleFonts.cairo(
                                            color: AppColors.lightCream,
                                            fontSize: 16,
                                          ),
                                        )
                                      : Center(),
                                  const SizedBox(width: 8),
                                  Flag.fromString(
                                    country.status,
                                    height: 24,
                                    width: 36,
                                  ),
                                ],
                              ),
                              onChanged: (sel) => setState(() {
                                _tempSelected = sel!;
                                _searchCtrl.text = sel.arabicName;
                                _focusNode.unfocus();
                                widget.onCountrySelected(sel);
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.accent70),
                            ),
                            child: Text(
                              "إلغاء",
                              style: GoogleFonts.cairo(
                                color: AppColors.lightCream,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                            ),
                            onPressed: () {
                              setState(() {
                                widget.onCountrySelected(_tempSelected);
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              "تأكيد",
                              style: GoogleFonts.cairo(
                                color: AppColors.lightCream,
                              ),
                            ),
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
      },
    );
  }
}
