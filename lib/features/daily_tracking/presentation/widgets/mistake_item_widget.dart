import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/core/models/mistake_type.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';
import '../../domain/entities/mistake.dart';
import '../bloc/tracking_session_bloc.dart';
import 'ayah_text_spans.dart';

/// A widget that displays a single mistake and allows the teacher to categorize it.
///
/// This is a "smart" widget that is driven by the [Mistake] data it receives
/// and dispatches [MistakeCategorized] events to the [TrackingSessionBloc]
/// when the user interacts with the [ChoiceChip]s.
class MistakeItemWidget extends StatelessWidget {
  /// The mistake data to display.
  final Mistake mistake;
  final Ayah ayah;

  const MistakeItemWidget({
    super.key,
    required this.mistake,
    required this.ayah,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: theme.colorScheme.surface.withOpacity(0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for displaying the Ayah text and highlighting the mistaken word.
            AyahTextSpans(allMistakes: [mistake], ayahsInSurah: [ayah]),
            const Divider(height: 20, thickness: 0.5),
            // A wrap of choice chips for categorizing the mistake.
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: MistakeType.values
                  .where((t) => t != MistakeType.none)
                  .map((type) {
                    final isSelected = mistake.mistakeType == type;
                    return ChoiceChip(
                      label: Text(type.labelAr),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (selected) {
                        context.read<TrackingSessionBloc>().add(
                          MistakeCategorized(
                            mistakeId: mistake.id, // Use the String UUID
                            newMistakeType: selected ? type : MistakeType.none,
                          ),
                        );
                      },
                    );
                  })
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
