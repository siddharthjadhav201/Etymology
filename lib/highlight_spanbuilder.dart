import 'dart:developer';

// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'providers.dart';

class HighlightSpanBuilder extends SpecialTextSpanBuilder {
  final HighlightProvider highlightProvider;

  HighlightSpanBuilder(this.highlightProvider);

 @override
TextSpan build(String data, {TextStyle? textStyle, onTap}) {
  final List<InlineSpan> children = [];
  // final wordRegEx = RegExp(r'(\s+|\S+)'); // Captures both words and spaces
  // final matches = wordRegEx.allMatches(data);
  List highlightedWordsLocations = highlightProvider.highlightedWordLocations.map((element){return element;}).toList();
  // List wordLocations=highlightedWords.values.toList();
  highlightedWordsLocations.sort((a, b) => a[0].compareTo(b[0]));
  int globalStart=0;
  for (final highlightedWordsLocation in highlightedWordsLocations) {
    children.add(TextSpan(
      text: data.substring(globalStart,highlightedWordsLocation[0]),
      style: textStyle?.copyWith(
        backgroundColor: null,
      ),
    ));
    children.add(TextSpan(
      text: data.substring(highlightedWordsLocation[0],highlightedWordsLocation[1]),
      style: textStyle?.copyWith(
            backgroundColor: Colors.yellow.withAlpha(128),
          ),
    ),
    );
    globalStart=highlightedWordsLocation[1];
  }
  children.add(TextSpan(
      text: data.substring(globalStart),
      style: textStyle?.copyWith(
        backgroundColor: null,
      ),
    ));

  return TextSpan(children: children, style: textStyle);


  }
  
  @override
  SpecialText? createSpecialText(String flag, {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, required int index}) {

    throw UnimplementedError();
  }

}