import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import 'package:tajalwaqaracademy/features/HalqasManagement/data/models/halqa.dart';
import 'package:tajalwaqaracademy/features/HalqasManagement/presentation/ui/screens/halqa_profile_screen.dart';
import 'package:tajalwaqaracademy/shared/widgets/taj.dart';

class HalqaRequestsScreen extends StatelessWidget {
  const HalqaRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: inactiveHalqas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 5),
                  itemBuilder: (ctx, i) {
                    return _buildHalqaCard(inactiveHalqas[i], ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHalqaCard(Halqa halqa, BuildContext context) {
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HalqaProfileScreen(
                // nameArabic: state.signInModel.nameArabic,
              ),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        leading: Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: const DecorationImage(
              image: AssetImage("assets/images/logo2.png"),
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                AppColors.darkBackground38,
                BlendMode.darken,
              ),
            ),
          ),
        ),

        title: Text(
          halqa.halqaName,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: AppColors.lightCream,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            halqa.country,
            style: GoogleFonts.cairo(fontSize: 12, color: AppColors.lightCream),
          ),
        ),
        trailing: StatusTag(status: halqa.status),
      ),
    );
  }
}
