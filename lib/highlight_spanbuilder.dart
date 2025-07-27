import 'package:etymology/highlight_block_formatter.dart';
import 'package:etymology/highlight_special_text.dart';
import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:etymology/providers.dart';
import 'package:etymology/overlay_helper.dart';

class HighlightSpanBuilder extends SpecialTextSpanBuilder {
  final HighlightProvider highlightProvider;
  final BuildContext context;

  HighlightSpanBuilder(this.highlightProvider, this.context);

  @override
  TextSpan build(String data, {TextStyle? textStyle, onTap}) {
    final List<InlineSpan> children = [];
    List highlightedWordsLocations =
        highlightProvider.highlightedRanges.map((element) {
      return element;
    }).toList();
    highlightedWordsLocations.sort((a, b) => a.start.compareTo(b.start));
    int globalStart = 0;

    for (HighlightedRange loc in highlightedWordsLocations) {
      children.add(TextSpan(
        text: data.substring(globalStart, loc.start),
        style: textStyle,
      ));

      final word = data.substring(loc.start, loc.end + 1);
      final key = GlobalKey(); // For precise tooltip positioning

      children.add(WidgetSpan(
        child: MouseRegion(
          key: key,
          onEnter: (_) {
            final info = highlightProvider.getInfoForWord(word);
            if (info != null && info.isNotEmpty) {
              OverlayHelper.showTooltip(
                context: context,
                key: key,
                info: info,
              );
            }
          },
          onExit: (_) {
            OverlayHelper.removeTooltip();
          },
          child: Text(
            word,
            style: textStyle?.copyWith(backgroundColor: Colors.yellow.withAlpha(128)),
          ),
        ),
      ));

      globalStart = loc.end + 1;
    }

    children.add(TextSpan(
      text: data.substring(globalStart),
      style: textStyle,
    ));

    return TextSpan(children: children, style: textStyle);
  }
  

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      required int index}) {
    return HighlightSpecialText(
      flag,
      textStyle,
      index,
      (word) {
        final info = highlightProvider.getInfoForWord(word);
        if (info != null) {
          highlightProvider.setSelectedWord(word, Map<String, dynamic>.from(info));
        }
      },
    );
  }
}

