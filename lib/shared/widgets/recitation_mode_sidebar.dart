// lib/features/daily_tracking/presentation/widgets/recitation_mode_sidebar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// Import the BLoC and its components
import '../../../../shared/themes/app_theme.dart';
import '../../../../shared/widgets/avatar.dart';
import '../../core/utils/app_assets.dart';

/// A fixed side navigation bar for the Quran reader screen.
///
/// This widget is stateless and driven entirely by the [TrackingSessionBloc].
/// It displays different tracking modes and dispatches events upon user interaction.
class RecitationModeSideBar extends StatelessWidget {
  final String title;
  final Avatar avatar;
  final List<CustomModeIconButton> items;

  const RecitationModeSideBar({
    super.key,
    required this.title,
    required this.avatar,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              fit: BoxFit.fitWidth,
              AppAssets.svg.dots,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.onSecondary,
                  Theme.of(context).colorScheme.onSecondary.withOpacity(0.2),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),

            child: Column(
              children: [
                ClipPath(
                  clipper: _HeaderClipper(),
                  child: Container(
                    color: Theme.of(context).colorScheme.onPrimary,
                    width: double.infinity,
                    height: 200,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        avatar,
                        SizedBox(width: 12),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: items.map((item) {
                      return _ModeIconButton(
                        icon: item.icon,
                        label: item.label,
                        isSelected: item.isSelected,
                        onTap: () => item.onTap(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    final Color activeColor =
        Theme.of(context).colorScheme.brightness == Brightness.dark
        ? AppColors.lightCream
        : Colors.black;
    final Color inactiveColor = activeColor.withOpacity(0.6);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
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

                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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

class CustomModeIconButton {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomModeIconButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
}
