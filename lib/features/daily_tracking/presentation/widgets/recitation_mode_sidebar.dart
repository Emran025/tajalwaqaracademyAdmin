// lib/features/daily_tracking/presentation/widgets/recitation_mode_sidebar.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/core/models/tracking_type.dart'; // Using the domain enum

// Import the BLoC and its components
import '../../../../shared/themes/app_theme.dart';
import '../../../../shared/widgets/avatar.dart';
import '../bloc/tracking_session_bloc.dart';

// Import the dialogs we will use later
import 'final_report_dialog.dart';

// Enum to represent the different tracking modes. Using an enum is safer
// and more readable than using strings or integers.
enum TrackingMode { memorize, review, recite, finalReport, back }

/// A fixed side navigation bar for the Quran reader screen.
///
/// This widget is stateless and driven entirely by the [TrackingSessionBloc].
/// It displays different tracking modes and dispatches events upon user interaction.
class RecitationModeSideBar extends StatelessWidget {
  const RecitationModeSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingSessionBloc, TrackingSessionState>(
      buildWhen: (previous, current) =>
          previous.currentTaskType != current.currentTaskType,
      builder: (context, state) {
        final selectedType = state.currentTaskType;
        return Drawer(
          backgroundColor: AppColors.accent,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.darkBackground],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),

            child: Column(
              children: [
                ClipPath(
                  clipper: _HeaderClipper(),
                  child: Container(
                    color: AppColors.mediumDark,
                    width: double.infinity,
                    height: 200,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Avatar(size: Size(100, 100)),
                        SizedBox(width: 12),
                        Text(
                          "مرحباً، عمران",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _ModeIconButton(
                        icon: Icons.bookmark_add,
                        label: TrackingType.memorization.labelAr,
                        isSelected: selectedType == TrackingType.memorization,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.read<TrackingSessionBloc>().add(
                            const TaskTypeChanged(
                              newType: TrackingType.memorization,
                            ),
                          );
                        },
                      ),
                      _ModeIconButton(
                        icon: Icons.menu_book,
                        label: TrackingType.review.labelAr,
                        isSelected: selectedType == TrackingType.review,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.read<TrackingSessionBloc>().add(
                            const TaskTypeChanged(newType: TrackingType.review),
                          );
                        },
                      ),
                      _ModeIconButton(
                        icon: Icons.record_voice_over,
                        label: TrackingType.recitation.labelAr,
                        isSelected: selectedType == TrackingType.recitation,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.read<TrackingSessionBloc>().add(
                            const TaskTypeChanged(
                              newType: TrackingType.recitation,
                            ),
                          );
                        },
                      ),

                      _ModeIconButton(
                        icon: Icons.assessment,
                        label: 'تقرير',
                        isSelected: false,
                        onTap: () {
                          // Action to show the final report dialog
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (_) => const FinalReportDialog(),
                          );
                        },
                      ),
                      _ModeIconButton(
                        icon: Icons.arrow_back,
                        label: 'عودة',
                        isSelected: false,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// The _ModeIconButton helper widget remains a pure presentation component.
class _ModeIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeIconButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Theme.of(context).colorScheme.onPrimary;
    final Color inactiveColor = Theme.of(
      context,
    ).colorScheme.onPrimary.withOpacity(0.6);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? activeColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? activeColor : inactiveColor,
                    fontSize: 16,

                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 40);
    p.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}
