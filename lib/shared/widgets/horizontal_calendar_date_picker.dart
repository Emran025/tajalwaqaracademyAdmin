import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';

class HorizontalCalendarDatePicker extends StatefulWidget {
  /// Called whenever the user taps a date.
  final ValueChanged<DateTime> onDateSelected;

  /// What date to show as “selected” when we first build.
  /// If null, defaults to today (clamped to [startDate]…[endDate]).
  final DateTime? initialDate;

  /// The first date in the scroll list.
  final DateTime startDate;

  /// The last date in the scroll list.
  final DateTime endDate;
  final double maxItemes;

  const HorizontalCalendarDatePicker({
    super.key,
    required this.onDateSelected,
    this.initialDate,
    required this.startDate,
    required this.endDate,
    this.maxItemes = 5,
  });

  @override
  State<HorizontalCalendarDatePicker> createState() =>
      _HorizontalCalendarDatePickerState();
}

class _HorizontalCalendarDatePickerState
    extends State<HorizontalCalendarDatePicker> {
  late final ScrollController _scrollController;
  late DateTime _selectedDate;

  // tweak this if you change your item styling
  static const double _itemWidth = 70;
  static const double _horizontalMargin = 6;

  @override
  void initState() {
    super.initState();
    // pick today if no initialDate, then clamp into [startDate…endDate]
    final today = DateTime.now();
    final raw = widget.initialDate ?? today;
    _selectedDate = _clampDate(raw, widget.startDate, widget.endDate);

    _scrollController = ScrollController();

    // after build, center the selected date
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  /// Keep d between `min` and `max`.
  DateTime _clampDate(DateTime d, DateTime min, DateTime max) {
    if (d.isBefore(min)) return min;
    if (d.isAfter(max)) return max;
    return d;
  }

  void _scrollToSelected() {
    final start = widget.startDate;
    // compute zero-based index from startDate
    final index = _selectedDate.difference(start).inDays;

    final fullItemWidth =
        _itemWidth + (_horizontalMargin * (10 * (1 / widget.maxItemes)));

    final screenWidth = MediaQuery.of(context).size.width;

    // center = offset + itemWidth/2  → we want that to sit at screenWidth/2
    final rawOffset =
        (index * fullItemWidth) - (screenWidth / 2) + (fullItemWidth / 2);

    // never ask for negative or beyond max scroll
    final max = _scrollController.position.hasContentDimensions
        ? _scrollController.position.maxScrollExtent
        : double.infinity;
    print(max);
    print(rawOffset);
    print(fullItemWidth);
    print(screenWidth);
    final target = rawOffset.clamp(0.0, max);

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalDays = widget.endDate.difference(widget.startDate).inDays + 1;

    return SizedBox(
      height: 110,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: totalDays,
        itemBuilder: (context, idx) {
          final date = widget.startDate.add(Duration(days: idx));
          final isSelected = _isSameDate(date, _selectedDate);
          final bgColor = isSelected
              ? AppColors.accent
              : AppColors.mediumDark38;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              widget.onDateSelected(date);
              _scrollToSelected();
            },
            child: Container(
              width: _itemWidth,
              margin: const EdgeInsets.symmetric(
                horizontal: _horizontalMargin,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'ar').format(date),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,

                      color: AppColors.lightCream54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d', 'ar').format(date),
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightCream,
                    ),
                  ),
                  Text(
                    DateFormat('MMM', 'ar').format(date),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightCream54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
