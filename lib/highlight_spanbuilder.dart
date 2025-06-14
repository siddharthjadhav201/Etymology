import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'providers.dart';

class HighlightSpanBuilder extends SpecialTextSpanBuilder {
  final HighlightProvider highlightProvider;

  HighlightSpanBuilder(this.highlightProvider);

 @override
TextSpan build(String data, {TextStyle? textStyle, onTap}) {
  final List<InlineSpan> children = [];
  final wordRegEx = RegExp(r'(\s+|\S+)'); // Captures both words and spaces
  final matches = wordRegEx.allMatches(data);

  for (final match in matches) {
    final part = match.group(0)!;
    final cleanPart = part.trim();
    final isHighlighted = highlightProvider.isHighlighted(cleanPart);

    children.add(TextSpan(
      text: part,
      style: textStyle?.copyWith(
        backgroundColor: isHighlighted ? Colors.yellow : null,
      ),
    ));
  }

  return TextSpan(children: children, style: textStyle);


  }
  
  @override
  SpecialText? createSpecialText(String flag, {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, required int index}) {
    // TODO: implement createSpecialText
    throw UnimplementedError();
  }

}