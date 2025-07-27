import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HighlightSpecialText extends SpecialText {
  final int start;
  final Function(String) onWordTap;
  HighlightSpecialText(
    String flag,
    TextStyle? textStyle,
    this.start,
    this.onWordTap,
  ) : super(flag, " ", textStyle);

  @override
  InlineSpan finishText() {
    final String word = toString();
    return TextSpan(
      text: word,
      style: textStyle?.copyWith(backgroundColor: Colors.yellow.withAlpha(128)),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          onWordTap(word);
        },
    );
  }
}
