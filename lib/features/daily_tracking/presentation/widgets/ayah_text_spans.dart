// lib/features/quran_reader/presentation/widgets/page_display_widget.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/core/models/mistake_type.dart';
import 'package:tajalwaqaracademy/core/utils/app_assets.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/mistake.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/bloc/tracking_session_bloc.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/widgets/ayah_text_span.dart';

class AyahTextSpans extends StatefulWidget {
  final List<Ayah> ayahsInSurah;
  final List<Mistake> allMistakes;
  const AyahTextSpans({
    super.key,
    required this.ayahsInSurah,
    required this.allMistakes,
  });

  @override
  State<AyahTextSpans> createState() => _AyahaTextSpansState();
}

class _AyahaTextSpansState extends State<AyahTextSpans> {
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        children: _buildTextSpans(
          context,
          widget.ayahsInSurah,
          widget.allMistakes,
        ),
      ),
    );
  }

  // In page_display_widget.dart
  List<TextSpan> _buildTextSpans(
    BuildContext context,
    List<Ayah> ayahs,
    List<Mistake> allMistakes,
  ) {
    return ayahs.asMap().entries.expand((entry) {
      // final int ayahIndexInList = entry.key;
      final Ayah ayah = entry.value;
      final double fontSize = 18;

      // 1. Filter mistakes for THIS SPECIFIC AYAH.
      final mistakesForThisAyah = allMistakes
          .where((m) => m.ayahIdQuran == ayah.number)
          .toList();
      // 1. Get the current session state to access the current task detail.
      final sessionState = context.read<TrackingSessionBloc>().state;
      final currentDetail = sessionState.currentTaskDetail;

      // 2. Pass this filtered list to buildWordSpans.
      final List<TextSpan> wordSpans = buildWordSpans(
        context: context,
        text: ayah.text.substring(0, ayah.text.length - 1),
        pageIndex: ayah.page,
        fontSize: fontSize,
        // Replace the old local state with the mistake data from the BLoC.
        mistakesForThisAyah: mistakesForThisAyah,

        ayah: ayah, // Pass the whole ayah object
        // 3. The onWordTap callback now dispatches an event to the BLoC.
        onWordTap: (tappedWordIndex) {
          // Safety check: Do not proceed if there is no active task detail.
          if (currentDetail == null) return;

          // Safety check: Do not proceed if there is no active task detail.

          context.read<TrackingSessionBloc>().add(
            WordTappedForMistake(
              ayahId: ayah.number,
              wordIndex: tappedWordIndex,
              newMistakeType: MistakeType.none,
            ),
          );
        },
      );

      // inside _buildTextSpans method
      // ... (the part that builds `wordSpans` remains the same)

      // The part for `endOfAyahSymbolSpan`
      final int endSymbolIndex = ayah.text.length - 1;
      final bool endSymbolMistake =
          int.parse(("${currentDetail?.gap ?? 0}").split('.').last) ==
          ayah.number;

      final TextSpan endOfAyahSymbolSpan = TextSpan(
        text: ayah.text.substring(endSymbolIndex),
        style: TextStyle(
          fontFamily: AppAssets.fonts.fontName(ayah.page),
          fontSize: 28,
          height: 1.5,
          letterSpacing: 2,
          color: endSymbolMistake
              ? Theme.of(context).colorScheme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black
              : const Color(0xFF5D371C),
          backgroundColor: endSymbolMistake
              ? const Color(0xffCD9974).withOpacity(.4)
              : Colors.transparent,

          // backgroundColor: endSymbolMistake != null
          //     ? Theme.of(context).colorScheme.error.withOpacity(0.4)
          //     : Colors.transparent,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // When the end-of-ayah symbol is tapped, we dispatch a different event.
            if (currentDetail == null) return;

            context.read<TrackingSessionBloc>().add(
              RecitationRangeEnded(pageNumber: ayah.page, ayah: ayah.number),
            );
            // We can also still log it as a mistake if needed.
            // context.read<TrackingSessionBloc>().add(
            //   WordTappedForMistake(ayahId: ayah.id, wordIndex: endSymbolIndex),
            // );
            // =================== END: NEW LOGIC ===================
          },
      );

      return [...wordSpans, endOfAyahSymbolSpan, const TextSpan(text: ' ')];
    }).toList();
  }
}
