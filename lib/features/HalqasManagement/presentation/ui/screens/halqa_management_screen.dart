import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import 'package:tajalwaqaracademy/features/HalqasManagement/data/models/halqa.dart';
import 'package:tajalwaqaracademy/features/HalqasManagement/presentation/ui/screens/add_halqas_screen.dart';
import 'package:tajalwaqaracademy/features/HalqasManagement/presentation/ui/screens/halqa_profile_screen.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';
import 'package:tajalwaqaracademy/shared/widgets/taj.dart';

class HalqaManagementScreen extends StatefulWidget {
  const HalqaManagementScreen({super.key});

  @override
  State<HalqaManagementScreen> createState() => _HalqaManagementScreenState();
}

class _HalqaManagementScreenState extends State<HalqaManagementScreen> {
  List<HalqasForm> forms = [HalqasForm(key: UniqueKey())];

  void _addForm() {
    setState(() {
      if (forms.last.formKey.currentState?.validate() ?? false) {
        forms.add(HalqasForm(key: UniqueKey()));
      }
    });
  }

  void _submitForms() {
    bool isSuccas = true;

    for (var form in forms) {
      if (form.formKey.currentState?.validate() ?? false) {
        form.formKey.currentState?.save();
      } else {
        isSuccas = false;
      }
    }
    if (isSuccas) {
      Navigator.pop(context);
    }
  }

  void _showAddHalqas() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.black45,
              insetPadding: const EdgeInsets.all(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: EdgeInsets.all(10),
                  constraints: BoxConstraints(maxHeight: 600),
                  decoration: BoxDecoration(
                    color: AppColors.accent12,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent70, width: 0.7),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.add,
                            color: AppColors.mediumDark87,
                            size: 40,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "إضافة حلقة",
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightCream,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Divider(height: 2, color: AppColors.accent70),
                      ),
                      Flexible(
                        child: Scrollbar(
                          thumbVisibility: true,
                          thickness: 2,
                          child: ListView.separated(
                            itemCount: forms.length,
                            separatorBuilder: (_, __) => Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Divider(
                                height: 2,
                                color: AppColors.accent70,
                              ),
                            ),
                            itemBuilder: (_, index) => forms[index],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => {Navigator.pop(context)},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.accent70),
                              ),
                              child: Text(
                                "الغاء",
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lightCream,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => {
                                // Navigator.pop(context),
                                setStateDialog(() {
                                  _addForm();
                                }),
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.accent70),
                              ),
                              child: Text(
                                "اضافة آخرى",
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lightCream,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                              ),
                              onPressed: () {
                                setState(() {
                                  _submitForms();
                                });
                              },
                              child: Text(
                                "حفظ",
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
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

  String _search = "";

  @override
  Widget build(BuildContext context) {
    final filtered = activeHalqas
        .where(
          (t) => t.country.contains(_search) || t.country.contains(_search),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0x00000000),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHalqas(),
        icon: Icon(Icons.add, color: AppColors.lightCream),
        label: Text(
          "إضافة حلقة",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: AppColors.lightCream,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 5),
                  itemBuilder: (ctx, i) {
                    return _buildHalqaCard(filtered[i], ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (val) => setState(() => _search = val),
      style: GoogleFonts.cairo(color: AppColors.lightCream),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.lightCream.withOpacity(0.1),
        prefixIcon: Icon(Icons.search, color: AppColors.lightCream),
        hintText: "ابحث عن حلقة...",
        hintStyle: GoogleFonts.cairo(color: AppColors.lightCream),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
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
        leading: Avatar(),
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
