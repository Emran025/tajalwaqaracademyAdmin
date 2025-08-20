import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/core/models/mistake_type.dart';

/// A widget that displays a row of selectable icons representing different mistake types.
/// This version is designed to be used in an Overlay for a hover-and-release interaction.
class MistakeTypeSelector extends StatelessWidget {
  /// The currently highlighted mistake type, controlled by the parent.
  final ValueNotifier<MistakeType?> highlightedType;
  final ValueChanged<MistakeType> onTypeSelected;

  // We define a fixed size for each icon button for easier hit-testing.
  static const double iconButtonSize = 50.0;
  static const List<MistakeType> selectableTypes = [
      MistakeType.memory, MistakeType.grammar, MistakeType.pronunciation, MistakeType.timing
  ];

  const MistakeTypeSelector({
    super.key,
    required this.highlightedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    // A simple container with a background to host the icons.
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 8.0,
      borderRadius: BorderRadius.circular(30.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ValueListenableBuilder<MistakeType?>(
          valueListenable: highlightedType,
          builder: (context, currentHighlight, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: selectableTypes
                  .map((type) => _buildMistakeIcon(context, type, type == currentHighlight))
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMistakeIcon(BuildContext context, MistakeType type, bool isHighlighted) {
   final IconData icon;
    final Color color;

    switch (type) {
      case MistakeType.memory:
        icon = Icons.psychology_alt_outlined;
        color = Colors.blue.shade600;
        break;
      case MistakeType.grammar:
        icon = Icons.spellcheck_rounded;
        color = Colors.green.shade600;
        break;
      case MistakeType.pronunciation:
        icon = Icons.record_voice_over_outlined;
        color = Colors.orange.shade700;
        break;
      case MistakeType.timing:
        icon = Icons.timer_outlined;
        color = Colors.purple.shade600;
        break;
      case MistakeType.none:
        // This case is excluded by the .where() filter above, but we handle it for safety.
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    final double scale = isHighlighted ? 1.3 : 1.0;

    return GestureDetector(
      onTap: () => onTypeSelected(type), // Also allow tapping
      child: Container(
        width: iconButtonSize,
        height: iconButtonSize,
        alignment: Alignment.center,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              if (isHighlighted)
                Text(type.labelAr, style: TextStyle(fontSize: 8, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}