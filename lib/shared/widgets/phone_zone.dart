import 'dart:ui';

import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
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
  late TextEditingController controller;
  late CountryModel selectedCountry;

  final int fieldCount = 2;
  List<TextEditingController> controllers = [];
  final List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < fieldCount; i++) {
      focusNodes.add(FocusNode());
    }
    controllers = [widget.zoneController, widget.phoneController];
    selectedCountry = widget.initialCountry;
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleInput(int index) {
    if (index < fieldCount - 1) {
      focusNodes[index + 1].requestFocus();
    } else {
      focusNodes[index].unfocus();
    }
  }

  void _handleKey(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        controllers[index].text.isEmpty &&
        index > 0) {
      focusNodes[index - 1].requestFocus();
      if (controllers[index - 1].text.isNotEmpty) {
        controllers[index - 1].text = controllers[index - 1].text.replaceRange(
          controllers[index - 1].text.length - 1,
          null,
          '',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 12, left: 14),
        // padding: const EdgeInsets.all(8),
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
          color: AppColors.lightCream.withOpacity(0.1),

          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: size.width / 4,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _changeDialog(controller, "رمز الدولة");
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Flag.fromString(
                        selectedCountry.status,
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
                      focusNode: FocusNode(), // for listening to backspace
                      onKey: (event) => _handleKey(event, 0),

                      child: TextFormField(
                        controller: controllers[0],
                        focusNode: focusNodes[0],
                        maxLength: 5,
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              required maxLength,
                            }) => null,

                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            print(val);
                            countries.forEach((element) {
                              if (element.countryCallingCode ==
                                  widget.zoneController.text) {
                                widget.zoneController.text =
                                    element.countryCallingCode;
                                selectedCountry = element;
                                widget.onCountryChanged;
                                _handleInput(0);
                              }
                            });
                          });
                        },

                        decoration: InputDecoration(
                          filled: false,
                          contentPadding: EdgeInsets.only(right: 8),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "|",
              style: GoogleFonts.cairo(
                fontSize: 25,
                color: AppColors.lightCream26,
              ),
            ),
            Expanded(
              child: RawKeyboardListener(
                focusNode: FocusNode(), // for listening to backspace
                onKey: (event) => _handleKey(event, 1),
                child: TextFormField(
                  controller: controllers[1],
                  focusNode: focusNodes[1],
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.cairo(color: AppColors.lightCream),
                  cursorColor: AppColors.lightCream,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    hintStyle: GoogleFonts.cairo(color: AppColors.lightCream70),
                    labelText: widget.label,
                    prefixStyle: GoogleFonts.cairo(
                      color: AppColors.lightCream70,
                    ),
                    labelStyle: GoogleFonts.cairo(
                      color: AppColors.lightCream70,
                    ),
                    filled: false,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),

                  onSaved: ((val) {
                    controller.text = val?.trim() ?? '';
                  }),
                  onChanged: ((val) {
                    print(val);
                    controller.text = val.trim();

                    val.length >= 11 ? _handleInput(1) : null;
                  }),
                  validator: (val) => (val == null || val.isEmpty)
                      ? " حقل ${widget.label} مطلوب"
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeDialog(TextEditingController residence, String title) {
    showDialog(
      context: context,
      builder: (_) => CountryPickerDialog(
        initialCountry: selectedCountry,
        onCountrySelected: (country) {
          setState(() {
            selectedCountry = country;
            widget.zoneController.text = country.countryCallingCode;
            residence.text = country.countryCallingCode;
            widget.onCountryChanged?.call();
            _handleInput(0);
          });
        },
        isCollingCode: true,
      ),
    );
  }
}
