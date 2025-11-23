import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';

import '../../../../../config/di/injection.dart';
import '../../bloc/supervisor_bloc.dart';

class ApplicantsProfileScreen extends StatefulWidget {
  final String applicantID;

  const ApplicantsProfileScreen({super.key, required this.applicantID});

  @override
  State<ApplicantsProfileScreen> createState() =>
      _ApplicantsProfileScreenState();
}

class _ApplicantsProfileScreenState extends State<ApplicantsProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SupervisorBloc>()
        ..add(
          ApplicantDetailsFetched(
            applicantId: UserRole.fromLabel(widget.applicantID),
          ),
        ),
      child: Scaffold(
        // backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          title: Text("الملف الشخصي للمتقدم"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<SupervisorBloc, SupervisorState>(
          builder: (context, state) {
            return const Center(child: Text("فشل تحميل التفاصيل"));
          },
        ),
      ),
    );
  }
}
