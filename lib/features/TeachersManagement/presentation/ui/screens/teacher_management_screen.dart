import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/config/di/injection.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/constants/countries_names.dart';
import 'package:tajalwaqaracademy/core/errors/error_model.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';
import 'package:tajalwaqaracademy/core/models/countery_model.dart';
import 'package:tajalwaqaracademy/core/models/gender.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/domain/entities/teacher_list_item_entity.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/presentation/bloc/teacher_bloc.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/presentation/ui/screens/add_teachers_screen.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';
import 'package:tajalwaqaracademy/shared/widgets/taj.dart';

import '../../../domain/entities/teacher_entity.dart';
import 'teacher_profile_screen.dart';

class TeacherManagementScreen extends StatefulWidget {
  const TeacherManagementScreen({super.key});

  @override
  State<TeacherManagementScreen> createState() =>
      _TeacherManagementScreenState();
}

class _TeacherManagementScreenState extends State<TeacherManagementScreen> {
  // The search query is the only piece of UI state we need to manage here.
  String _search = "";
  FocusNode focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add a listener to the scroll controller to detect when the user reaches the end.
    _scrollController.addListener(_onScroll);
  }

  // This is the correct place to trigger the initial data fetch.
  // We do it in the BlocProvider's create method.

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Best practice: Unfocus the search bar only if the user scrolls down (away from top) and the search bar is focused.
    // If the user scrolls up (towards top), keep the search bar focused for a better search experience.
    if (focusNode.hasFocus &&
        _scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
      focusNode.unfocus();
    }
  }

  void _showAddTeachersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Provide the existing TeacherBloc to the dialog.
      builder: (_) => BlocProvider.value(
        value: context.read<TeacherBloc>(),
        child: const AddTeacherDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // The screen is responsible for creating the BLoC and dispatching the initial event.
      create: (context) => sl<TeacherBloc>()..add(const WatchTeachersStarted()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddTeachersDialog,
          icon: Icon(Icons.add, color: AppColors.lightCream),
          label: Text(
            "إضافة معلم",
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: AppColors.lightCream,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 10),
                Expanded(
                  // Use a BlocBuilder because this part only needs to rebuild based on state.
                  // ...
                  child: BlocBuilder<TeacherBloc, TeacherState>(
                    builder: (context, state) {
                      // --- Central Loading Indicator ---
                      if (state.status == TeacherStatus.loading &&
                          state.teachers.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // --- Central Failure View ---
                      if (state.status == TeacherStatus.failure &&
                          state.teachers.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Error: state.failure?.message'),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<TeacherBloc>()
                                    .add(const TeachersRefreshed()),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        );
                      }

                      // --- Empty State View ---
                      if (state.status == TeacherStatus.success &&
                          state.teachers.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<TeacherBloc>().add(
                              const TeachersRefreshed(),
                            );
                            // The refresh completes when the BLoC emits a new state.
                          },
                          child: const Center(
                            child: Text('No teachers found.'),
                          ),
                        );
                      }

                      // --- Main Content (Success or Loading with existing data) ---
                      // The ListView is always visible if there's data, even during a refresh.
                      final filteredTeachers = state.teachers
                          .where(
                            (t) =>
                                t.name.contains(_search) ||
                                t.country.contains(_search),
                          )
                          .toList();
                      return RefreshIndicator(
                        onRefresh: () async {
                          if (state.status == TeacherStatus.success &&
                              state.hasMorePages &&
                              !state.isLoadingMore) {
                            context.read<TeacherBloc>().add(
                              const TeachersRefreshed(),
                            );
                          }
                          // The refresh completes when the BLoC emits a new state.
                        },
                        child: ListView.separated(
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 5),
                          controller:
                              _scrollController, // Controller for "load more"
                          itemCount:
                              filteredTeachers.length +
                              (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (ctx, i) {
                            if (i >= filteredTeachers.length) {
                              // "Load More" indicator
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _buildTeacherCard(filteredTeachers[i], ctx);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      focusNode: focusNode,
      onTapOutside: (n) => focusNode.unfocus(),
      onChanged: (val) => setState(() => _search = val),
      style: GoogleFonts.cairo(color: AppColors.lightCream),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.lightCream.withOpacity(0.1),
        prefixIcon: Icon(Icons.search, color: AppColors.lightCream),
        hintText: "ابحث عن معلم...",
        hintStyle: GoogleFonts.cairo(color: AppColors.lightCream),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // --- UNIFIED Teacher Card Widget ---
  // We only need one card widget that works with the TeacherDetailEntity from our domain.
  Widget _buildTeacherCard(
    TeacherListItemEntity teacher,
    BuildContext context,
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TeacherProfileScreen(teacherId: teacher.id),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        leading: Avatar(gender: teacher.gender, pic: teacher.avatar),
        title: Text(
          teacher.name,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: AppColors.lightCream,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            "${teacher.country} - ${teacher.city}",
            style: GoogleFonts.cairo(fontSize: 12, color: AppColors.lightCream),
          ),
        ),
        trailing: StatusTag(status: teacher.status),
      ),
    );
  }
}

// --- Corrected AddTeacherDialog ---
// No major changes needed here, but I've cleaned up the "Cancel" button logic.

// Create a new StatefulWidget for the dialog to manage its own state and controllers.
class AddTeacherDialog extends StatefulWidget {
  //   // All controllers are created here, inside the dialog's scope.

  const AddTeacherDialog({super.key});

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  // You can still manage UI-only state here, like selected countries
  late CountryModel selectedPhoneZone;
  late CountryModel selectedwhatsAppZone;
  late CountryModel selectedCountry;
  late TimeOfDay availableTime;
  @override
  void initState() {
    selectedPhoneZone = countries[245];
    selectedwhatsAppZone = countries[245];
    selectedCountry = countries[245];
    availableTime = TimeOfDay.now();
    super.initState();
  }

  List<TeacherForm> forms = [TeacherForm(key: UniqueKey())];
  void _addForm() {
    setState(() {
      if (forms.last.formKey.currentState?.validate() ?? false) {
        forms.add(TeacherForm(key: UniqueKey()));
      }
    });
  }

  void _submitForms(BuildContext context) {
    bool isSuccas = true;

    for (var form in forms) {
      if (form.formKey.currentState?.validate() ?? false) {
        form.formKey.currentState?.save();
        if (form.formKey.currentState?.validate() ?? false) {
          // 1. Create the TeacherDetailEntity from the controllers' values
          final newTeacher = TeacherDetailEntity(
            id: '', // UUID will be generated by the data layer
            name: form.nameController.text,
            gender: Gender.fromLabel(
              form.genderController.text == 'Male' ||
                      form.genderController.text == 'ذكر'
                  ? 'ذكر'
                  : 'أنثى',
            ),
            birthDate: form.birthDateController.text,
            email: form.emailController.text,
            phone: form.phoneController.text,
            phoneZone: int.parse(form.phoneZoneController.text),
            whatsAppPhone: form.whatsAppPhoneController.text,
            whatsAppZone: int.parse(form.whatsAppZoneController.text),
            qualification: form.qualificationController.text,
            experienceYears: int.parse(form.experienceYearsController.text),
            country: form.countryController.text,
            residence: form.residenceController.text,
            city: '',
            availableTime: availableTime,
            status: ActiveStatus.active,
            stopReasons: '',
            avatar: '',
            bio: "خبرة لخمس سنوات",
            halqas: [],
            createdAt: "${DateTime.now()}",
            updatedAt: "${DateTime.now()}",
          );

          // 2. Add the event to the BLoC
          context.read<TeacherBloc>().add(TeacherUpserted(newTeacher));
        } else {
          isSuccas = false;
        }
      }
      if (isSuccas) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the BLoC for submission states
    return BlocProvider.value(
      value: sl<TeacherBloc>(),
      child: BlocConsumer<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state.upsertStatus == TeacherUpsertStatus.success) {
            // On success, close the dialog
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Teacher saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.upsertStatus == TeacherUpsertStatus.failure) {
            // On failure, show an error message

            // Now we can be more specific about the error.
            final failure = state.failure;
            String message;
            IconData icon;

            if (failure is NetworkFailure) {
              message = 'No Internet Connection. Please check your network.';
              icon = Icons.wifi_off;
            } else if (failure is CacheFailure) {
              message = 'Error reading from local data. Please try again.';
              icon = Icons.storage_rounded;
            } else {
              message = 'An unexpected error occurred.';
              icon = Icons.error_outline;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
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
                                "حاول مجددًا",
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
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final Size size = MediaQuery.of(context).size;
          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(10),
                    constraints: BoxConstraints(maxHeight: size.height - 80),
                    decoration: BoxDecoration(
                      color: AppColors.accent12,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accent70, width: 0.7),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Drag handle
                        Container(
                          width: 75,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.lightCream70,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Center(
                              child: const Icon(
                                Icons.add,
                                color: AppColors.lightCream,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "اضافة ملف الأستاذ",
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightCream,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
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
                                  setState(() {
                                    _addForm();
                                  }),
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.accent70),
                                ),
                                child: Text(
                                  "اضافة آخر",
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
                                    _submitForms(context);
                                  });
                                },
                                child: Text(
                                  "حفظ",
                                  style: GoogleFonts.cairo(
                                    color: AppColors.lightCream,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
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
          );
        },
      ),
    );
  }
}
