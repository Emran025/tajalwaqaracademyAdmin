import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';

import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';

import '../../../../../config/di/injection.dart';
import '../../../../../shared/widgets/taj.dart';
import '../../../domain/entities/teacher_entity.dart';
import '../../bloc/teacher_bloc.dart';

class TeacherProfileScreen extends StatefulWidget {
  final String teacherId;
  const TeacherProfileScreen({super.key, required this.teacherId});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final List<Map<String, dynamic>> circles = [
    {'name': 'حلقة الفاروق', 'students': 12, 'level': 'متقدم'},
    {'name': 'حلقة البخاري', 'students': 9, 'level': 'مبتدئ'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // The screen is responsible for creating the BLoC and dispatching the initial event.
      create: (context) =>
          sl<TeacherBloc>()..add(TeacherDetailsFetched(widget.teacherId)),
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          title: Text("الملف الشخصي"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<TeacherBloc, TeacherState>(
          builder: (context, status) {
            if (status.detailsStatus == TeacherDetailsStatus.failure) {
              return const Text('Failed to load details');
            } else if (status.detailsStatus == TeacherDetailsStatus.success) {
              // When success, the data will be in `state.selectedTeacher`.
              // Another BlocBuilder can be used to display the actual data.
              return Directionality(
                textDirection: TextDirection.rtl,
                child: SafeArea(
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    children: [
                      _buildHeader(context, status.selectedTeacher!),
                      SizedBox(height: 24),
                      _buildInfoRow("البريد", status.selectedTeacher!.email),

                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              "الجنس",
                              status.selectedTeacher!.gender.labelAr,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoRow(
                              "الجنسية",
                              status.selectedTeacher!.country,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              "بلد الإقامة",
                              status.selectedTeacher!.residence,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoRow(
                              "المدينة",
                              status.selectedTeacher!.city,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              "رقم الهاتف",
                              status.selectedTeacher!.phone,
                            ),
                          ),
                          SizedBox(width: 8),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: _buildInfoRow(
                              "",
                              "${status.selectedTeacher!.phoneZone}",
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              "رقم الواتس",
                              status.selectedTeacher!.whatsAppPhone,
                            ),
                          ),
                          SizedBox(width: 8),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: _buildInfoRow(
                              "",
                              "${status.selectedTeacher!.whatsAppZone}",
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              "المؤهل",
                              status.selectedTeacher!.qualification,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildInfoRow("العمر", "20")),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoRow(
                              "سنوات العمل",
                              " ${status.selectedTeacher!.experienceYears}",
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            // onTap: () => _showStudentReports(),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.accent70,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_note_sharp,
                                    color: AppColors.lightCream70,
                                    size: 30,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "تعديل البيانات",
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lightCream87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              height: 2,
                              color: AppColors.accent70,
                            ),
                          ),
                        ],
                      ),

                      if (status.selectedTeacher!.status ==
                          ActiveStatus.active) ...[
                        SizedBox(height: 15),
                        Text(
                          "الحلقات",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            color: AppColors.lightCream70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...circles.map(
                          (circle) => _buildCircleCard(context, circle),
                        ),
                      ] else ...[
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: AppColors.accent70),
                                ),
                                child: Text(
                                  "رفض",
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: AppColors.accent,
                                ),
                                onPressed: () {
                                  // setState(() {
                                  //   residence.text = tempSelected;
                                  // });
                                  // Navigator.pop(context);
                                },
                                child: Text(
                                  "قبول",
                                  style: GoogleFonts.cairo(
                                    color: AppColors.lightCream,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TeacherDetailEntity teacher) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightCream12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightCream38),
      ),
      child: Row(
        children: [
          Avatar(gender: teacher.gender), // teacher.pic),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  teacher.name,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightCream,
                  ),
                ),
                SizedBox(height: 15),
                StatusTag(status: teacher.status, fontSize: 12),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mediumDark87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${teacher.halqas.length} حلقات",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: AppColors.lightCream,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightCream12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(color: AppColors.lightCream70)),
          Text(value, style: GoogleFonts.cairo(color: AppColors.lightCream)),
        ],
      ),
    );
  }

  Widget _buildCircleCard(BuildContext context, Map<String, dynamic> circle) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => CircleProfileScreen(circleName: circle['name'])),
        // );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accent70,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.book, color: Colors.teal),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circle['name'],
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightCream87,
                    ),
                  ),
                  Text(
                    "المستوى: ${circle['level']}",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.lightCream87,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${circle['students']} طالب",
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.lightCream87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
