import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/models/report_frequency.dart';
import 'package:tajalwaqaracademy/core/models/tracking_type.dart';
import 'package:tajalwaqaracademy/core/models/tracking_units.dart';
import 'package:tajalwaqaracademy/shared/widgets/custom_text_field.dart';

class StudentsPlanForm extends StatefulWidget {
  final formKey = GlobalKey<FormState>();

  StudentsPlanForm({super.key});

  @override
  State<StudentsPlanForm> createState() => _StudentsPlanFormState();
}

class _StudentsPlanFormState extends State<StudentsPlanForm> {
  // Controllers
  TextEditingController studyPlanType = TextEditingController(text: "يوميًا");

  Map<TrackingType, TextEditingController> unitTypeControllers = {
    TrackingType.memorization: TextEditingController(text: "صفحة"),
    TrackingType.review: TextEditingController(text: "صفحة"),
    TrackingType.recitation: TextEditingController(text: "صفحة"),
  };
  final Map<TrackingType, TextEditingController> quantityControllers = {
    TrackingType.memorization: TextEditingController(),
    TrackingType.review: TextEditingController(),
    TrackingType.recitation: TextEditingController(),
  };

  // Widget داخل الـ build

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "خطة المتابعة",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.lightCream87,
            ),
          ),
          const SizedBox(height: 10),
          _buildDropdown(
            studyPlanType,
            "نوع خطة المتابعة",
            Frequency.values.map((element) => element.labelAr).toList(),
          ),
          ...TrackingType.values.toList().map(
            (type) => Column(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    "إعدادات ال${type.labelAr}",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightCream70,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        unitTypeControllers[type]!,
                        "وحدة ال${type.labelAr}",
                        TrackingUnit.values
                            .map((element) => element.labelAr)
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: quantityControllers[type]!,
                        prefixIcon: Icons.format_list_numbered,
                        label: "العدد",
                        keyboardType: TextInputType.number,
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        style: GoogleFonts.cairo(color: AppColors.lightCream70),
        borderRadius: BorderRadius.circular(14),
        value: controller.text.trim(),
        dropdownColor: AppColors.mediumDark,

        items: options
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: GoogleFonts.cairo(
                    color: AppColors.lightCream70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (val) => setState(() => controller.text = val ?? "صفحة"),
        onSaved: (val) => controller.text = val ?? "صفحة",
        padding: EdgeInsets.all(0),
        decoration: InputDecoration(
          fillColor: AppColors.lightCream12,
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: AppColors.lightCream70),
        ),
      ),
    );
  }
}
