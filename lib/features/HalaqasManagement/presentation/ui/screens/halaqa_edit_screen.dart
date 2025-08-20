import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import 'package:tajalwaqaracademy/shared/widgets/taj.dart';

import '../../../../StudentsManagement/domain/entities/student_entity.dart';
import '../../../domain/entities/halqa.dart';


class HalaqaEditScreen extends StatefulWidget {
  const HalaqaEditScreen({super.key});
  @override
  State<HalaqaEditScreen> createState() => _HalaqaEditScreenState();
}

class _HalaqaEditScreenState extends State<HalaqaEditScreen>
    with TickerProviderStateMixin {
  List<String> teachers = ["أ. خالد", "أ. سمير", "أ. فاطمة"];
  Halqa halqa = Halqa(
    '0',
    "حلقة كبار السن",
    "اليمن - اب",
    TimeOfDay.now(),
    "أ. خالد",
  );

  late List<StudentDetailEntity> currentStudents;
  late List<StudentDetailEntity> availableStudents;

  @override
  void initState() {
    availableStudents = fakeStudents1;
    currentStudents = fakeStudents1;

    super.initState();
  }

  void _showStudentPickerDialog() {
    List<StudentDetailEntity> tempSelected = [...currentStudents];
    TextEditingController searchController = TextEditingController();
    List<StudentDetailEntity> filtered = [...availableStudents];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.black45,
            insetPadding: EdgeInsets.all(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(16),
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
                          filtered = availableStudents
                              .where((s) => s.name == val)
                              .toList();
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
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: AppColors.lightCream26),
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
                                  if (val == true) {
                                    tempSelected.add(student);
                                  } else {
                                    tempSelected.remove(student);
                                  }
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
                                currentStudents.clear();
                                currentStudents.addAll(tempSelected);
                                currentStudents.addAll(
                                  tempSelected.where(
                                    (s) => !currentStudents.contains(s),
                                  ),
                                );
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
          );
        },
      ),
    );
  }

  void _changeTeacherDialog() {
    String tempSelected = halqa.teacher;
    TextEditingController searchController = TextEditingController();
    List<String> filteredTeachers = [...teachers];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: AppColors.lightCream12,
            insetPadding: EdgeInsets.all(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(16),
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
                      controller: searchController,
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
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: AppColors.lightCream26),
                          itemBuilder: (_, i) {
                            final teacher = filteredTeachers[i];
                            return RadioListTile<String>(
                              value: teacher,
                              groupValue: tempSelected,
                              activeColor: AppColors.accent,
                              title: Text(
                                teacher,
                                style: GoogleFonts.cairo(
                                  color: AppColors.lightCream,
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  tempSelected = val!;
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
                                halqa.teacher = tempSelected;
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
          );
        },
      ),
    );
  }

  Widget _buildStudentCard(
    StudentDetailEntity student,
    void Function()? onPressed,
  ) {
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
        leading: student.avatar != ''
            ? CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage(student.avatar), // صور رمزية
              )
            : CircleAvatar(
                backgroundColor: AppColors.accent,
                radius: 15,
                child: Text(
                  student.name.substring(0, 1),
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightCream,
                  ),
                ),
              ),
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
        onTap: () {},
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                onPressed!();
              },
              child: StatusTag(lable: "اتخاذ اجراء"),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: AppColors.lightCream),
              onPressed: () => {},
            ),
          ],
        ),
      ),
    );
  }

  void _editHalqaNameDialog() {
    TextEditingController nameController = TextEditingController(
      text: halqa.halqaName,
    );

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.lightCream.withOpacity(0.1),
        insetPadding: const EdgeInsets.all(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightCream.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.lightCream38),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit, color: AppColors.lightCream),
                    const SizedBox(width: 8),
                    Text(
                      "تعديل اسم الحلقة",
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightCream,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.cairo(color: AppColors.lightCream),
                  cursorColor: AppColors.lightCream,
                  decoration: InputDecoration(
                    hintText: "ادخل اسم الحلقة الجديد...",
                    hintStyle: GoogleFonts.cairo(color: AppColors.lightCream70),
                    labelText: "اسم الحلقة",
                    labelStyle: GoogleFonts.cairo(
                      color: AppColors.lightCream70,
                    ),
                    prefixIcon: const Icon(
                      Icons.school,
                      color: AppColors.lightCream,
                    ),
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
                ),
                const SizedBox(height: 24),
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
                          style: GoogleFonts.cairo(color: AppColors.lightCream),
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
                            halqa.halqaName = nameController.text.trim();
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          "تأكيد",
                          style: GoogleFonts.cairo(color: AppColors.lightCream),
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
  }

  void _showStudentActionDialog(StudentDetailEntity student) {
    String action = "";
    TextEditingController noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: AppColors.lightCream.withOpacity(0.1),
            insetPadding: EdgeInsets.all(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent12,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent70, width: 0.7),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "إدارة الطالب",
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightCream,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ["نقل", "فصل", "إيقاف"].map((action1) {
                        final isSelected = action == action1;
                        return ChoiceChip(
                          label: Text(
                            action1,
                            style: GoogleFonts.cairo(
                              color: isSelected
                                  ? AppColors.lightCream
                                  : AppColors.mediumDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.accent,
                          backgroundColor: AppColors.accent70.withOpacity(0.3),
                          onSelected: (_) =>
                              setStateDialog(() => action = action1),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.lightCream26,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "أضف ملاحظة (اختياري)",
                        hintStyle: GoogleFonts.cairo(
                          color: AppColors.lightCream70,
                        ),
                        filled: true,
                        fillColor: AppColors.lightCream12,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.cairo(color: AppColors.lightCream),
                    ),
                    SizedBox(height: 16),
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
                              if (action == "نقل") {
                                setState(() {
                                  currentStudents.remove(student);
                                  // add to previous + note
                                });
                              } else if (action == "فصل" || action == "إيقاف") {
                                setState(() {
                                  // stoppedStatus[student] = true;
                                });
                              }
                              Navigator.pop(context);
                            },
                            child: Text(
                              "تنفيذ",
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          "تعديل الحلقة",
          style: GoogleFonts.cairo(color: AppColors.lightCream),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // كرت للمعلم والإضافة
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.lightCream12,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.lightCream12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInfoRow(
                          icon: Icons.school,
                          label: "اسم الحلقة:",
                          value: halqa.halqaName,
                          onEdit: _editHalqaNameDialog,
                        ),
                        const SizedBox(height: 16),
                        buildInfoRow(
                          icon: Icons.person,
                          label: "المعلم الحالي:",
                          value: halqa.teacher,
                          onEdit: _changeTeacherDialog,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.group_add,
                              color: AppColors.lightCream70,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "أضف طلاب للحلقة:",
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                color: AppColors.lightCream,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _showStudentPickerDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: AppColors.lightCream,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "اختر طلاب",
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
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
              SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, color: AppColors.accent),
                      SizedBox(width: 8),
                      Text(
                        "الطلاب الحاليين",
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightCream,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "${currentStudents.length}",
                        style: GoogleFonts.cairo(
                          color: AppColors.lightCream,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 400,
                    child: ListView.separated(
                      itemCount: availableStudents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        return _buildStudentCard(availableStudents[i], () {
                          _showStudentActionDialog(availableStudents[i]);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyLog {
  final DateTime dateTime;
  final String memorization;
  final String recitation;
  final String revison;
  final String notes;

  DailyLog(
    this.dateTime,
    this.recitation,
    this.revison,
    this.memorization,
    this.notes,
  );
}

Widget buildInfoRow({
  required IconData icon,
  required String label,
  required String value,
  required VoidCallback onEdit,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(icon, color: AppColors.lightCream70, size: 20),
      const SizedBox(width: 8),
      Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 16,
          color: AppColors.lightCream,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.lightCream12,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.lightCream12),
        ),
        child: Text(
          value,
          style: GoogleFonts.cairo(
            color: AppColors.lightCream,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const Spacer(),
      ElevatedButton.icon(
        onPressed: onEdit,
        icon: const Icon(Icons.edit, size: 18),
        label: Text(
          "تغيير",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mediumDark87,
          foregroundColor: AppColors.lightCream,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    ],
  );
}
