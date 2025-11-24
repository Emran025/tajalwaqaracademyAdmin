import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/applicant_profile_entity.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/presentation/bloc/supervisor_bloc.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/presentation/ui/widgets/approve_applicant_dialog.dart';

import '../../../../../core/models/gender.dart';

class ApplicantProfileScreen extends StatefulWidget {
  final int applicantId;

  const ApplicantProfileScreen({super.key, required this.applicantId});

  @override
  State<ApplicantProfileScreen> createState() => _ApplicantProfileScreenState();
}

class _ApplicantProfileScreenState extends State<ApplicantProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupervisorBloc>().add(
      ApplicantProfileFetched(widget.applicantId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملف المقدم')),
      body: BlocListener<SupervisorBloc, SupervisorState>(
        listener: (context, state) {
          if (state is SupervisorLoaded && state.applicantProfile == null) {
            Navigator.of(context).pop();
          }
        },
        child: BlocBuilder<SupervisorBloc, SupervisorState>(
          builder: (context, state) {
            if (state is SupervisorLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SupervisorLoaded &&
                state.applicantProfile != null) {
              return _buildSuccessfulUI(context, state.applicantProfile!);
            } else if (state is SupervisorError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('فشل تحميل الملف الشخصي'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildSuccessfulUI(
    BuildContext context,
    ApplicantProfileEntity applicant,
  ) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            _buildHeader(context, applicant.user),
            const SizedBox(height: 24),
            _buildInfoRow('البريد الإلكتروني', applicant.user.email),
            _buildInfoRow('رقم الهاتف', applicant.user.phone),
            _buildInfoRow('الجنس', applicant.user.gender),
            _buildInfoRow('الدولة', applicant.user.country),
            _buildInfoRow('المدينة', applicant.user.city),
            _buildInfoRow('المؤهلات', applicant.qualifications),
            _buildInfoRow('بيان النوايا', applicant.intentStatement),
            const SizedBox(height: 24),
            _buildActionButtons(context, applicant),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ApplicantProfileEntity applicant,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(onPressed: null, child: const Text('رفض')),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<SupervisorBloc>(context),
                  child: ApproveApplicantDialog(
                    applicantId: applicant.id,
                    onConfirm: () {
                      context.read<SupervisorBloc>().add(
                        ApproveApplicant(applicant.id),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            },
            child: const Text('قبول'),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, UserEntity user) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.lightCream.withOpacity(0.1)
            : AppColors.mediumDark70,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightCream38),
      ),
      child: Row(
        children: [
          Avatar(gender: Gender.fromLabel(user.gender), pic: user.avatar),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightCream,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'مقدم جديد',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.lightCream,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.lightCream12
            : AppColors.mediumDark87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(color: AppColors.lightCream70)),
          Text(
            value ?? '',
            style: GoogleFonts.cairo(color: AppColors.lightCream),
          ),
        ],
      ),
    );
  }
}
