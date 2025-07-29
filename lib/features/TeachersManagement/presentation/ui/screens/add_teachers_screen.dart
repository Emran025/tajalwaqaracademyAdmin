import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/constants/countries_names.dart';
import 'package:tajalwaqaracademy/core/models/countery_model.dart';
import 'package:tajalwaqaracademy/shared/func/date_format.dart';
import 'package:tajalwaqaracademy/shared/widgets/country_picker_dialog.dart';
import 'package:tajalwaqaracademy/shared/widgets/custom_text_field.dart';
import 'package:tajalwaqaracademy/shared/widgets/phone_zone.dart';
import 'package:tajalwaqaracademy/shared/widgets/pick_date.dart';

class TeacherForm extends StatefulWidget {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController genderController = TextEditingController(
    text: "Male",
  );
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController phoneZoneController = TextEditingController();
  final TextEditingController whatsAppPhoneController = TextEditingController();
  final TextEditingController whatsAppZoneController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController experienceYearsController =
      TextEditingController();
  final TextEditingController eneregyController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController residenceController = TextEditingController();
  final TextEditingController memorizationLevelController =
      TextEditingController();
  final TextEditingController availableTimeController = TextEditingController();

  TeacherForm({super.key});

  @override
  State<TeacherForm> createState() => _TeacherFormState();
}

class _TeacherFormState extends State<TeacherForm> {
  // late TextEditingController name;
  // late TextEditingController gender;
  // late TextEditingController email;
  // late TextEditingController birthDate;
  // late TextEditingController phone;
  // late TextEditingController phoneZone;
  // late TextEditingController whatsAppPhone;
  // late TextEditingController whatsAppZone;
  // late TextEditingController qualification;
  // late TextEditingController experienceYears;
  // late TextEditingController eneregy;
  // late TextEditingController country;
  // late TextEditingController residence;
  // late TextEditingController memorizationLevel;
  // late TextEditingController availableTime;
  late CountryModel selectedPhoneZone;
  late CountryModel selectedwhatsAppZone;
  late CountryModel selectedCountry;

  @override
  void initState() {
    selectedPhoneZone = countries[245];
    selectedwhatsAppZone = countries[245];
    selectedCountry = countries[245];
    //   name = TextEditingController();
    //   gender = TextEditingController(text: "Male");
    //   email = TextEditingController();
    //   birthDate = TextEditingController();
    //   phone = TextEditingController();
    //   phoneZone = TextEditingController();
    //   whatsAppPhone = TextEditingController();
    //   whatsAppZone = TextEditingController();
    //   qualification = TextEditingController();
    //   experienceYears = TextEditingController();
    //   eneregy = TextEditingController();
    //   country = TextEditingController();
    //   residence = TextEditingController();
    //   memorizationLevel = TextEditingController();
    //   availableTime = TextEditingController();
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Container(
        margin: EdgeInsets.only(bottom: 5, top: 10),
        child: Column(
          children: [
            CustomTextField(
              controller: widget.nameController,
              prefixIcon: Icons.person,
              label: "اسم المعلم",
              keyboardType: TextInputType.name,
            ),
            _buildDropdown(widget.genderController, "الجنس", [
              "Male",
              "Female",
            ]),
            CustomTextField(
              controller: widget.emailController,
              prefixIcon: Icons.email,
              label: "البريد الإلكتروني",
              keyboardType: TextInputType.emailAddress,
            ),
            CustomDatePicker(
              controller: widget.birthDateController,
              icon: Icons.calendar_month_outlined,
              label: "تأريخ الميلاد",
              onDateSelected: (date) {
                widget.birthDateController.text = formatDate(date);
                // birthDate.text = date
                //     .toIso8601String()
                //     .split('T')
                //     .first; // Format date to YYYY-MM-DD;
              },
            ),

            PhoneZoneForm(
              phoneController: widget.phoneController,
              zoneController: widget.phoneZoneController,
              initialCountry: selectedPhoneZone,
              onCountryChanged: () {
                setState(() {
                  selectedPhoneZone = countries
                      .where(
                        (x) =>
                            x.countryCallingCode ==
                            widget.phoneZoneController.text,
                      )
                      .first;
                });
              },
              label: "رقم الهاتف",
            ),
            PhoneZoneForm(
              phoneController: widget.whatsAppPhoneController,
              zoneController: widget.whatsAppZoneController,
              initialCountry: selectedwhatsAppZone,
              onCountryChanged: () {
                setState(() {
                  selectedwhatsAppZone = countries
                      .where(
                        (x) =>
                            x.countryCallingCode ==
                            widget.phoneZoneController.text,
                      )
                      .first;
                });
              },
              label: "رقم الواتسآب",
            ),

            CustomTextField(
              controller: widget.qualificationController,
              prefixIcon: Icons.school,
              label: "المؤهل العلمي",
            ),
            CustomTextField(
              controller: widget.experienceYearsController,
              prefixIcon: Icons.calendar_month,
              label: "سنوات الخبرة",
              keyboardType: TextInputType.number,
            ),
            CustomTextField(
              controller: widget.eneregyController,
              prefixIcon: Icons.group,
              label: "الطاقة الإستيعابية",
              keyboardType: TextInputType.number,
            ),
            CustomTextField(
              controller: widget.countryController,
              prefixIcon: Icons.home_filled,
              label: "محل الميلاد",
              onTap: _changeDialog,
              readOnly: true,
            ),
            CustomTextField(
              controller: widget.residenceController,
              prefixIcon: Icons.home_filled,
              label: "بلد الإقامة",
              onTap: _changeDialog,
              readOnly: true,
            ),
            CustomTextField(
              controller: widget.memorizationLevelController,
              prefixIcon: Icons.subtitles_outlined,
              keyboardType: TextInputType.number,
              label: "المقرر",
            ),
            CustomTextField(
              controller: widget.availableTimeController,
              prefixIcon: Icons.timelapse_rounded,
              label: "الوقت المتاح",
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
            residence.text = country.arabicName;
          });
        },
        isCollingCode: true,
      ),
    );
  }

  Widget _buildDropdown(
    TextEditingController controller,
    String label,
    List<String> options,
  ) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 12, left: 14),
      child: DropdownButtonFormField<String>(
        itemHeight: 50,
        style: GoogleFonts.cairo(color: AppColors.lightCream70),
        borderRadius: BorderRadius.circular(14),
        value: controller.text.trim(),
        dropdownColor: AppColors.mediumDark,
        items: options
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e == "Male" ? "ذكر" : "أنثى",
                  style: GoogleFonts.cairo(
                    color: AppColors.lightCream70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (val) => setState(() => controller.text = val ?? "Male"),
        onSaved: (val) => controller.text = val ?? "Male",
        decoration: InputDecoration(
          fillColor: AppColors.lightCream12,
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: AppColors.lightCream70),
        ),
      ),
    );
  }
}
