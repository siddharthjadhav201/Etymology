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
  Map highlightedWords= highlightProvider.highlightedWords;
  List wordLocations=highlightedWords.values.toList();
  wordLocations.sort((a, b) => a[0].compareTo(b[0]));
  int globalStart=0;
  for (final wordLocation in wordLocations) {
    // final part = match.group(0)!;
    // final cleanPart = part.trim();
    // final isHighlighted = highlightProvider.isHighlighted(cleanPart);
    children.add(TextSpan(
      text: data.substring(globalStart,wordLocation[0]),
      style: textStyle?.copyWith(
        backgroundColor: null,
      ),
    ));
    children.add(TextSpan(
      text: data.substring(wordLocation[0],wordLocation[1]+1),
      style: textStyle?.copyWith(
        backgroundColor: Colors.yellow.withOpacity(0.7) ,
        
      ),
    ));
    globalStart=wordLocation[1]+1;
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
    // TODO: implement createSpecialText
    throw UnimplementedError();
  }

}