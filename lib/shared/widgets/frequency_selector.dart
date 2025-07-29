import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/models/report_frequency.dart';

class FrequencySelector extends StatelessWidget {
  final Frequency selected;
  final ValueChanged<Frequency> onChanged;

  const FrequencySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SegmentedButton<Frequency>(
          segments: Frequency.values
              .map(
                (freq) => ButtonSegment<Frequency>(
                  value: freq,
                  label: Text(
                    freq.labelAr,
                    style: GoogleFonts.cairo(fontSize: 12),
                  ),
                ),
              )
              .toList(growable: false),
          selected: {selected},
          onSelectionChanged: (newSel) {
            final f = newSel.first;
            if (f != selected) onChanged(f);
          },
        ),
      ),
    );
  }
}
