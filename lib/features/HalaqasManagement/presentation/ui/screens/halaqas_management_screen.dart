import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/config/di/injection.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/constants/countries_names.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';
import 'package:tajalwaqaracademy/core/models/countery_model.dart';
import 'package:tajalwaqaracademy/core/models/gender.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';

import '../../../../../shared/widgets/caerd_tile.dart';
import '../../../domain/entities/halaqa_entity.dart';
import '../../../domain/entities/halaqa_list_item_entity.dart';
import '../../bloc/halaqa_bloc.dart';
import 'add_halaqas_screen.dart';
import 'halaqa_profile_screen.dart';

class HalaqaManagementScreen extends StatefulWidget {
  const HalaqaManagementScreen({super.key});

  @override
  State<HalaqaManagementScreen> createState() => _HalaqaManagementScreenState();
}

class _HalaqaManagementScreenState extends State<HalaqaManagementScreen> {
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

  void _showAddHalaqasDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Provide the existing TeacherBloc to the dialog.
      builder: (_) => BlocProvider.value(
        value: context.read<HalaqaBloc>(),
        child: const AddHalaqaDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // The screen is responsible for creating the BLoC and dispatching the initial event.
      create: (context) => sl<HalaqaBloc>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                _showAddHalaqasDialog(context);
              },
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
                padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 10),
                    Expanded(
                      // Use a BlocBuilder because this part only needs to rebuild based on state.
                      // ...
                      child: BlocBuilder<HalaqaBloc, HalaqaState>(
                        builder: (context, state) {
                          // --- Central Loading Indicator ---
                          if (state.status == HalaqaStatus.loading &&
                              state.halaqas.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          // --- Central Failure View ---
                          if (state.status == HalaqaStatus.failure &&
                              state.halaqas.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Error: state.failure?.message'),
                                  ElevatedButton(
                                    onPressed: () => context
                                        .read<HalaqaBloc>()
                                        .add(const HalaqasRefreshed()),
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            );
                          }

                          // --- Empty State View ---
                          if (state.status == HalaqaStatus.success &&
                              state.halaqas.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                context.read<HalaqaBloc>().add(
                                  const HalaqasRefreshed(),
                                );
                                // The refresh completes when the BLoC emits a new state.
                              },
                              child: const Center(
                                child: Text('No halaqas found.'),
                              ),
                            );
                          }

                          // --- Main Content (Success or Loading with existing data) ---
                          // The ListView is always visible if there's data, even during a refresh.
                          final filteredHalaqas = state.halaqas
                              .where(
                                (t) =>
                                    t.name.contains(_search) ||
                                    t.country.contains(_search),
                              )
                              .toList();
                          return RefreshIndicator(
                            onRefresh: () async {
                              if (state.status == HalaqaStatus.success &&
                                  state.hasMorePages &&
                                  !state.isLoadingMore) {
                                context.read<HalaqaBloc>().add(
                                  const HalaqasRefreshed(),
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
                                  filteredHalaqas.length +
                                  (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (ctx, i) {
                                if (i >= filteredHalaqas.length) {
                                  // "Load More" indicator
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return _buildHalaqaCard(filteredHalaqas[i]);
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
          );
        },
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
        fillColor: Theme.of(
          context,
        ).colorScheme.primaryContainer.withOpacity(0.3),
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.87),
        ),
        hintText: "ابحث عن حلقة...",
        hintStyle: Theme.of(context).textTheme.bodyLarge,
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

  // --- UNIFIED Halaqa Card Widget ---
  // We only need one card widget that works with the HalaqaDetailEntity from our domain.
  Widget _buildHalaqaCard(HalaqaListItemEntity halaqa) {
    return CustomListTile(
      title: halaqa.name,
      moreIcon: Icons.more_vert,
      leading: Avatar(gender: halaqa.gender, pic: halaqa.avatar),
      subtitle: "${halaqa.country} - ${halaqa.residence}",
      backgroundColor: AppColors.accent12,
      hasMoreIcon: false,
      tajLable: halaqa.status.labelAr,
      border: Border.all(color: AppColors.accent70, width: 0.5),
      onMoreTab: () => {},
      onListTilePressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HalaqaProfileScreen(halaqaId: halaqa.id),
          ),
        );
      },
      onTajPressed: () {},
    );
  }
}

// --- Corrected AddHalaqaDialog ---
// No major changes needed here, but I've cleaned up the "Cancel" button logic.

// Create a new StatefulWidget for the dialog to manage its own state and controllers.
class AddHalaqaDialog extends StatefulWidget {
  //   // All controllers are created here, inside the dialog's scope.

  const AddHalaqaDialog({super.key});

  @override
  State<AddHalaqaDialog> createState() => _AddHalaqaDialogState();
}

class _AddHalaqaDialogState extends State<AddHalaqaDialog> {
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

  List<HalaqaForm> forms = [HalaqaForm(key: UniqueKey())];
  void _addForm() {
    setState(() {
      if (forms.last.formKey.currentState?.validate() ?? false) {
        forms.add(HalaqaForm(key: UniqueKey()));
      }
    });
  }

  void _submitForms(BuildContext context) {
    bool isSuccas = true;

    for (var form in forms) {
      if (form.formKey.currentState?.validate() ?? false) {
        form.formKey.currentState?.save();
        if (form.formKey.currentState?.validate() ?? false) {
          // 1. Create the HalaqaDetailEntity from the controllers' values
          final newHalaqa = HalaqaDetailEntity(
            id: '', // UUID will be generated by the data layer
            name: form.nameController.text,
            gender: Gender.fromLabel(
              form.genderController.text == 'Male' ||
                      form.genderController.text == 'ذكر'
                  ? 'ذكر'
                  : 'أنثى',
            ),
            country: form.countryController.text,
            residence: form.residenceController.text,
            status: ActiveStatus.active,
            avatar: '',
            createdAt: "${DateTime.now()}",
            updatedAt: "${DateTime.now()}",
            sumOfStudents: 0,
            maxOfStudents:
                int.tryParse(form.eneregyController.text.trim()) ?? 0,
            teacherId: 0,
          );

          // 2. Add the event to the BLoC
          context.read<HalaqaBloc>().add(HalaqaUpserted(newHalaqa));
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
      value: sl<HalaqaBloc>(),
      child: BlocConsumer<HalaqaBloc, HalaqaState>(
        listener: (context, state) {
          if (state.upsertStatus == HalaqaUpsertStatus.success) {
            // On success, close the dialog
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Halaqa saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.upsertStatus == HalaqaUpsertStatus.failure) {
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
                              "بناء حلقة",
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
