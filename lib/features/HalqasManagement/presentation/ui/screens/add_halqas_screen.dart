import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/constants/countries_names.dart';
import 'package:tajalwaqaracademy/core/models/countery_model.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import 'package:tajalwaqaracademy/features/HalqasManagement/data/models/halqa.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/student_entity.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';
import 'package:tajalwaqaracademy/shared/widgets/country_picker_dialog.dart';
import 'package:tajalwaqaracademy/shared/widgets/custom_text_field.dart';

class HalqasForm extends StatefulWidget {
  final formKey = GlobalKey<FormState>();

  HalqasForm({super.key});

  @override
  State<HalqasForm> createState() => _HalqasFormState();
}

class _HalqasFormState extends State<HalqasForm> {
  List<String> teachers = ["أ. خالد", "أ. سمير", "أ. فاطمة"];

  TextEditingController halqaName = TextEditingController();
  TextEditingController teacher = TextEditingController();
  TextEditingController gender = TextEditingController(text: "Male");
  TextEditingController country = TextEditingController();
  TextEditingController residence = TextEditingController();
  TextEditingController availableTime = TextEditingController();

  Halqa halqa = Halqa(
    '1',
    "حلقة كبار السن",
    "اليمن - اب",
    TimeOfDay.now(),
    "أ. خالد",
  );

  late List<StudentDetailEntity> currentStudents;
  late List<StudentDetailEntity> availableStudents;

  late CountryModel selectedCountry;
  @override
  void initState() {
    availableStudents = [...fakeStudents];
    currentStudents = [...fakeStudents];

    selectedCountry = countries[245];

    super.initState();
  }

  void _showStudentPickerDialog() {
    List<StudentDetailEntity> tempSelected = [...currentStudents];
    TextEditingController searchController = TextEditingController();
    List<StudentDetailEntity> filtered = [...availableStudents];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStatee) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.black45,
              insetPadding: EdgeInsets.all(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  constraints: BoxConstraints(maxHeight: 500),
                  decoration: BoxDecoration(
                    color: AppColors.accent12,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent70, width: 0.7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "إضافة طلاب للحلقة",
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightCream,
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: searchController,
                        style: GoogleFonts.cairo(color: AppColors.lightCream),
                        onChanged: (val) {
                          setState(() {
                            setStatee(() {
                              filtered = availableStudents
                                  .where((s) => s.name == val)
                                  .toList();
                            });
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "ابحث عن طالب...",
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
                      SizedBox(height: 12),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: AppColors.lightCream26,
                            ),
                            itemBuilder: (_, i) {
                              final student = filtered[i];
                              final selected = tempSelected.contains(student);
                              return CheckboxListTile(
                                value: selected,
                                title: Text(
                                  student.name,
                                  style: GoogleFonts.cairo(
                                    color: AppColors.lightCream,
                                  ),
                                ),
                                activeColor: AppColors.accent,
                                onChanged: (val) {
                                  setState(() {
                                    setStatee(() {
                                      if (val == true) {
                                        tempSelected.add(student);
                                      } else {
                                        tempSelected.remove(student);
                                      }
                                    });
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
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
                                  setStatee(() {
                                    currentStudents.clear();
                                    currentStudents.addAll(tempSelected);
                                    currentStudents.addAll(
                                      tempSelected.where(
                                        (s) => !currentStudents.contains(s),
                                      ),
                                    );
                                  });
                                });
                                Navigator.pop(context);
                              },
                              child: Text(
                                "إضافة",
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Container(
        margin: EdgeInsets.only(bottom: 5, top: 10),
        child: Column(
          children: [
            CustomTextField(
              controller: halqaName,
              prefixIcon: Icons.person,
              label: "اسم الحلقة",
              // "ادخل اسم الحلقة الجديد...",
              keyboardType: TextInputType.name,
            ),
            CustomTextField(
              controller: teacher,
              prefixIcon: Icons.person,
              label: "اسم المعلم",
              // "ادخل اسم الحلقة الجديد...",
              keyboardType: TextInputType.none,
              onTap: _changeTeacherDialog,
              readOnly: true,
            ),
            _buildDropdown(gender, "الجنس", ["Male", "Female"]),

            CustomTextField(
              controller: country,
              prefixIcon: Icons.home_filled,
              label: "البلد",
              keyboardType: TextInputType.none,
              onTap: _changeCountriesDialog,
              readOnly: true,
            ),
            CustomTextField(
              controller: availableTime,
              prefixIcon: Icons.timelapse_rounded,
              label: "الوقت المتاح",
            ),
            GestureDetector(
              onTap: () => _showStudentPickerDialog(),
              child: Row(
                children: [
                  const Icon(Icons.add, color: AppColors.mediumDark87),
                  const SizedBox(width: 8),
                  Text(
                    "إضافة طلاب",
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightCream,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Divider(height: 2, color: AppColors.accent70),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: SingleChildScrollView(
                child: Scrollbar(
                  child: Column(
                    children: currentStudents
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: _buildStudentCard(f),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentDetailEntity student) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent70, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        leading: Avatar(gender: student.gender),
        title: Text(
          student.name,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: AppColors.lightCream,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            student.status.labelAr,
            style: GoogleFonts.cairo(fontSize: 12, color: AppColors.lightCream),
          ),
        ),

        trailing: IconButton(
          icon: Icon(
            Icons.playlist_remove_rounded,
            color: AppColors.lightCream,
          ),
          onPressed: () {
            setState(() {
              currentStudents.remove(student);
            });
          },
        ),
      ),
    );
  }

  void _changeTeacherDialog(TextEditingController controller, String title) {
    String tempSelected = teacher.text;
    List<String> filteredTeachers = [...teachers];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.black45,
              insetPadding: EdgeInsets.all(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  constraints: BoxConstraints(maxHeight: 500),
                  decoration: BoxDecoration(
                    color: AppColors.accent12,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent70, width: 0.7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "تغيير المعلم",
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightCream,
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: teacher,
                        style: GoogleFonts.cairo(color: AppColors.lightCream),
                        onChanged: (val) {
                          setState(() {
                            filteredTeachers = teachers
                                .where((t) => t.contains(val))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "ابحث عن معلم...",
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
                      SizedBox(height: 12),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.separated(
                            itemCount: filteredTeachers.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: AppColors.lightCream26,
                            ),
                            itemBuilder: (_, i) {
                              final teacherName = filteredTeachers[i];
                              return RadioListTile<String>(
                                value: teacherName,
                                groupValue: tempSelected,
                                activeColor: AppColors.accent,
                                title: Text(
                                  teacherName,
                                  style: GoogleFonts.cairo(
                                    color: AppColors.lightCream,
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    tempSelected = val!;
                                    teacher.text = tempSelected;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
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
                                  teacher.text = tempSelected;
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
      ),
    );
  }

  void _changeCountriesDialog(TextEditingController residence, String title) {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 14),
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
