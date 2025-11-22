import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/countries_names.dart';
import 'package:tajalwaqaracademy/core/models/countery_model.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';
import 'package:tajalwaqaracademy/shared/widgets/country_picker_dialog.dart';
import 'package:tajalwaqaracademy/shared/widgets/custom_text_field.dart';

import '../../../../../core/models/active_status.dart';
import '../../../../../core/models/gender.dart';
import '../../../../../shared/themes/app_theme.dart';

import '../../../../../shared/widgets/pick_time.dart';
import '../../../../StudentsManagement/domain/entities/student_list_item_entity.dart';

class HalaqaForm extends StatefulWidget {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController genderController = TextEditingController(
    text: "Male",
  );
  final TextEditingController emailController = TextEditingController();
  final TextEditingController teacher = TextEditingController();
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

  HalaqaForm({super.key});

  @override
  State<HalaqaForm> createState() => _HalaqaFormState();
}

class _HalaqaFormState extends State<HalaqaForm> {
  List<String> teachers = ["أ. خالد", "أ. سمير", "أ. فاطمة"];

  late List<StudentListItemEntity> currentStudents;
  late List<StudentListItemEntity> availableStudents;

  late CountryModel selectedCountry;
  @override
  void initState() {
    availableStudents = [...fakeStudents];
    currentStudents = [...fakeStudents];

    selectedCountry = countries[245];

    super.initState();
  }

  void _showStudentPickerDialog() {
    List<StudentListItemEntity> tempSelected = [...currentStudents];
    TextEditingController searchController = TextEditingController();
    List<StudentListItemEntity> filtered = [...availableStudents];

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
              backgroundColor: AppColors.lightCream.withOpacity(0.1),
              insetPadding: EdgeInsets.all(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  constraints: BoxConstraints(maxHeight: 500),
                  decoration: BoxDecoration(
                    color: AppColors.lightCream.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.lightCream26),
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
              controller: widget.nameController,
              prefixIcon: Icons.person,
              label: "اسم الحلقة",
              keyboardType: TextInputType.name,
            ),
            _buildDropdown(widget.genderController, "الجنس", [
              "Male",
              "Female",
            ]),
            CustomTextField(
              controller: widget.eneregyController,
              prefixIcon: Icons.group,
              label: "الطاقة الإستيعابية",
              keyboardType: TextInputType.number,
            ),

            CustomTextField(
              controller: widget.residenceController,
              prefixIcon: Icons.home_filled,
              label: "البلد",
              onTap: _changeDialog,
              readOnly: true,
            ),

            CustomTimePicker(
              controller: widget.availableTimeController,
              icon: Icons.timelapse_rounded,
              label: "الوقت المتاح",
              onTimeSelected: (date) {
                widget.availableTimeController.text = "$date";
              },
            ),
            CustomTextField(
              controller: widget.teacher,
              prefixIcon: Icons.person,
              label: "اسم المعلم",
              // "ادخل اسم الحلقة الجديد...",
              keyboardType: TextInputType.none,
              onTap: _changeTeacherDialog,
              readOnly: true,
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

  Widget _buildStudentCard(StudentListItemEntity student) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
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
            student.status.label,
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
    String tempSelected = widget.teacher.text;
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
              backgroundColor: AppColors.lightCream.withOpacity(0.1),
              insetPadding: EdgeInsets.all(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  constraints: BoxConstraints(maxHeight: 500),
                  decoration: BoxDecoration(
                    color: AppColors.lightCream.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.lightCream26),
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
                        controller: widget.teacher,
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
                                    widget.teacher.text = tempSelected;
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
                                  widget.teacher.text = tempSelected;
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

final List<StudentListItemEntity> fakeStudents = [
  StudentListItemEntity(
    status: ActiveStatus.active,
    city: "اب",
    id: "11",
    name: "أحمد سعيد",
    avatar: "assets/images/u1.png",

    gender: Gender.male,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "12",
    name: "ليلى محمد",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u2.png",

    gender: Gender.female,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "13",
    name: "سعيد خالد",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u1.png",
    gender: Gender.male,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "14",
    name: "منى عبد الرحمن",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u2.png",

    gender: Gender.female,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "15",
    name: "خالد يوسف",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u1.png",

    gender: Gender.male,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "16",
    name: "سارة حسن",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u2.png",

    gender: Gender.female,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "17",
    name: "مريم علي",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u2.png",

    gender: Gender.female,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "18",
    name: "يوسف إبراهيم",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u1.png",

    gender: Gender.male,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "19",
    name: "هدى سمير",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u2.png",

    gender: Gender.female,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "20",
    name: "إبراهيم محمد",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u1.png",

    gender: Gender.male,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "21",
    name: "سامي عبد الله",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u1.png",

    gender: Gender.male,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "22",
    name: "مها خالد",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u2.png",

    gender: Gender.female,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "23",
    name: "علي سعيد",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u1.png",

    gender: Gender.male,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "24",
    name: "سلمى محمد",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u2.png",

    gender: Gender.female,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "25",
    name: "حسن إبراهيم",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u1.png",

    gender: Gender.male,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "26",
    name: "ريم علي",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u2.png",

    gender: Gender.female,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "27",
    name: "سعيد فؤاد",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u1.png",

    gender: Gender.male,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "28",
    name: "منى عبد الرحمن",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u2.png",

    gender: Gender.female,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
  StudentListItemEntity(
    id: "29",
    name: "يوسف سامي",
    status: ActiveStatus.active,
    city: "اب",
    avatar: "assets/images/u1.png",

    gender: Gender.male,
    country: countries[Random().nextInt(countries.length)].arabicName,
  ),
];
