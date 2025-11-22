import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Selector extends StatefulWidget {
  final String selected;
  final List<String> items;
  final ValueChanged<int> onChanged;

  const Selector({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<Selector> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SegmentedButton<String>(
          segments: widget.items
              .map(
                (item) => ButtonSegment<String>(
                  value: item,
                  label: Text(item, style: GoogleFonts.cairo(fontSize: 12)),
                ),
              )
              .toList(growable: false),
          selected: {widget.selected},
          onSelectionChanged: (newSel) {
            setState(() {
              final f = newSel.first;
              if (f != widget.selected) {
                widget.onChanged(widget.items.indexOf(f) + 1);
              }
            });
          },
        ),
      ),
    );
  }
}
