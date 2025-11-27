import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/mistake_type.dart';
import '../../../../core/utils/app_assets.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/mistake.dart';

/// A callback function signature for when a single word in an ayah is tapped.
///
/// Provides the zero-based index of the tapped word within the ayah.
typedef WordTapCallback = void Function(int wordIndex);

/// Builds a list of interactive TextSpans from an ayah's text, where each
/// "word" is represented by two characters.
///
/// This function splits the input [text] into two-character chunks, creating
/// a tappable [TextSpan] for each. It's designed for granular interaction,
/// such as word-by-word tafsir or analysis.
///
/// @param text The source text of the ayah to be processed.
/// @param context The build context for accessing theme data.
/// @param pageIndex The page number, used here for font selection.
/// @param onWordTap The callback function that fires when a word is tapped,
///        providing the index of that word within the ayah.
/// @returns A `TextSpan` that can be directly used in a `RichText` widget.

/// Builds a list of interactive TextSpans representing the words of an ayah.
/// Each character in the input text is treated as a "word".// The callback signature changes slightly.

List<TextSpan> buildWordSpans({
  required BuildContext context,
  required String text,
  required int pageIndex,
  required List<Mistake> mistakesForThisAyah, // Changed from List<int>
  required WordTapCallback onWordTap,
  double? fontSize,
  required Ayah ayah, // Changed from int ayahIndex
}) {
  if (text.isEmpty) return [];

  final List<TextSpan> spans = [];
  final String fontFamily = AppAssets.fonts.fontName(pageIndex);

  for (int i = 0; i < text.length; i++) {
    final String char = text[i];

    // Find the specific mistake object for this character index, if it exists.
    final Mistake? mistake = mistakesForThisAyah.firstWhereOrNull(
      (m) => m.wordIndex == i,
    );

    if (char == r'\') spans.add(TextSpan(text: '\n'));
    if (char == r'\' || char == r'n') continue;

    // else {
    spans.add(
      wordspan(
        word: char,
        fontFamily: fontFamily,
        mistake: mistake, // Use the new boolean
        fontSize: fontSize,
        wordIndex: i,
        onWordTap: onWordTap,
        context: context,
      ),
    );
    // }
  }

  return spans;
}

TextSpan wordspan({
  required String word,
  required String fontFamily,
  required Mistake? mistake,
  double? fontSize,
  required int wordIndex,
  required WordTapCallback
  onWordTap, // The parameter `ayahIndex` is no longer needed here
  required BuildContext context,
}) {
  if (word.isNotEmpty) {
    final Color backgroundColor;
    if (mistake != null) {
      switch (mistake.mistakeType) {
        case MistakeType.memory:
          backgroundColor = Colors.blue.withOpacity(0.4);
          break;
        case MistakeType.grammar:
          backgroundColor = Colors.green.withOpacity(0.4);
          break;
        case MistakeType.pronunciation:
          backgroundColor = Colors.orange.withOpacity(0.4);
          break;
        case MistakeType.timing:
          backgroundColor = Colors.purple.withOpacity(0.4);
          break;
        default:
          // The default color for an uncategorized mistake
          backgroundColor = Theme.of(
            context,
          ).colorScheme.error.withOpacity(0.4);
          break;
      }
    } else {
      backgroundColor = Colors.transparent;
    }
    return TextSpan(
      text: word,
      // style: TextStyle(
      //   fontFamily: fontFamily,
      //   fontSize: fontSize,
      //   height: 2.4,
      //   letterSpacing: 2,
      //   color: Theme.of(context).colorScheme.secondary,
      //   // The background color is now driven by `hasBookMark`, which comes from the BLoC state.
      //   backgroundColor: hasBookMark
      //       ? Theme.of(context).colorScheme.error.withOpacity(0.4) // Example new color
      //       : Colors.transparent,
      // ),
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        height: 2.4,
        letterSpacing: 2,
        color: Theme.of(context).colorScheme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        backgroundColor: backgroundColor,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          onWordTap(wordIndex); // Just pass the index
        },
    );
  } else {
    return const TextSpan(text: '');
  }
}
